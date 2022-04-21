namespace :neural_net do 


  task :train => :environment do 
    require "neural-net/neural_net"

    puts "Loading deck lists"
    data_by_format = {}
    classes_by_formats = {}
    deck_lists = DeckList.where.not(human_archetype_id: nil).joins(:human_archetype).where(archetypes: {format_id: Format.enabled.pluck(:id)})
    card_ids_by_format = deck_lists.all.inject({}){|cards,dl| 
      cards[dl.human_archetype.format_id] ||= []
      cards[dl.human_archetype.format_id] |= dl.deck_entries.pluck(:card_id)
      cards
    }
    deck_lists.includes(:deck_entries).find_each(batch_size: 1000) do |deck_list|
      classes = ( classes_by_formats[deck_list.human_archetype.format_id] ||= [])
      classes << deck_list.human_archetype_id
      cids = deck_list.deck_entries.pluck(:card_id)
      data_by_format[deck_list.human_archetype.format_id] ||= []
      data_by_format[deck_list.human_archetype.format_id] << {
        archetype: deck_list.human_archetype_id,
        cards: card_ids_by_format[deck_list.human_archetype.format_id].map {|cid| cids.include?(cid) ? 1.0 : 0.0}
      }
    end
    classes_by_formats.each {|format, classes| classes.uniq! }

    io_pair_by_format = {}
    data_by_format.each do |format, data|
      io_pair = []
      io_pair_by_format[format] = io_pair
      classes = classes_by_formats[format]
      data.each do |row|
        rowvec = NMatrix.new([1,row[:cards].size], row[:cards] + [1.0])
        io_pair << [rowvec, NMatrix.new([1,classes.size], classes.map{|c| c == row[:archetype] ? 1.0 : 0.0})] 
      end
    end

    io_pair_by_format.each do |format, io_pair|
      classes = classes_by_formats[format]
      puts "Training #{format}"
      io_pair.shuffle!
      split = (io_pair.size * 0.8).round
      train = io_pair[0..split]
      test  = io_pair[(split+1)..-1]

      net = NeuralNet.new(
        outfunc: ->(x){softmax x },
        hid1func: ->(x){sigmoid x},
        deriv1func: ->(x){
          s = sigmoid(x)
          s * (NMatrix.ones(x.shape) - s)
        },
      )
      net.init_weights(
        inputs: (io_pair[0][0].size-1),
        outs: classes.size,
        hidden1: 50,
      )
      net.classes = classes
      last = 2000
      eta = 0.5
      current_test_error = 1
      deltas = []
      check_interval = 100
      count = 0
      12.times do |i|
        train.shuffle!
        net.eta = eta
        train.each do |s|
          delta = net.train s[0], s[1]
        end
        puts "Run #{i}"
        test_error = print_errors net, test, train
        if test_error < current_test_error
          File.open("#{ArchetypesPersistencePrefix}-#{format}-card-ids.ser",  'wb') { |file| file.write(Marshal.dump(card_ids_by_format[format].to_a)) }
          net.save("#{ArchetypesPersistencePrefix}-#{format}")
          current_test_error = test_error
        end
        eta *= 0.95
      end
      puts "finished training"
      puts "Training size: #{train.size}"
      puts "Testing size: #{test.size}"
    end
  end 
  task :train_all => :environment do 
    require "neural-net/neural_net"

    puts "Loading deck lists"
    data = []
    classes = []
    deck_lists = DeckList.where.not(human_archetype_id: nil)
    card_ids= deck_lists.all.inject([]){|cards,dl| 
      cards |= dl.deck_entries.pluck(:card_id)
      cards
    }
    deck_lists.includes(:deck_entries).find_each(batch_size: 1000) do |deck_list|
      classes << deck_list.human_archetype_id
      cids = deck_list.deck_entries.pluck(:card_id)
      data << {
        archetype: deck_list.human_archetype_id,
        cards: card_ids.map {|cid| cids.include?(cid) ? 1.0 : 0.0}
      }
    end
    classes.uniq!

    io_pair = []
    data.each do |row|
      rowvec = NMatrix.new([1,row[:cards].size], row[:cards] + [1.0])
      io_pair << [rowvec, NMatrix.new([1,classes.size], classes.map{|c| c == row[:archetype] ? 1.0 : 0.0})] 
    end

    puts "Training"
    io_pair.shuffle!
    split = (io_pair.size * 0.8).round
    train = io_pair[0..split]
    test  = io_pair[(split+1)..-1]

    net = NeuralNet.new(
      outfunc: ->(x){softmax x },
      hid1func: ->(x){sigmoid x},
      deriv1func: ->(x){
        s = sigmoid(x)
        s * (NMatrix.ones(x.shape) - s)
      },
    )
    net.init_weights(
      inputs: (io_pair[0][0].size-1),
      outs: classes.size,
      hidden1: 40,
    )
    net.classes = classes
    last = 2000
    eta = 0.5
    current_test_error = 1
    deltas = []
    check_interval = 100
    count = 0
    25.times do |i|
      train.shuffle!
      net.eta = eta
      train.each do |s|
        delta = net.train s[0], s[1]
      end
      puts "Run #{i}"
      test_error = print_errors net, test, train
      if test_error < current_test_error
        File.open("#{ArchetypesPersistencePrefix}-all-card-ids.ser",  'wb') { |file| file.write(Marshal.dump(card_ids.to_a)) }
        net.save("#{ArchetypesPersistencePrefix}-all")
        current_test_error = test_error
      end
      eta *= 0.95
    end
    puts "finished training"
    puts "Training size: #{train.size}"
    puts "Testing size: #{test.size}"
  end 


  task :predict => :environment do 
    require "neural-net/neural_net"
    require 'colorize'
    nets_by_formats = {}
    card_ids_by_format = {}
    Format.enabled.each do |format|
      file = "#{ArchetypesPersistencePrefix}-#{format.id}-card-ids.ser"
      if File.exists?(file)
        all_card_ids = Marshal.load(File.read(file))
        card_ids_by_format[format.id] = all_card_ids
        net = NeuralNet.new(
          outfunc: ->(x){softmax x },
          hid1func: ->(x){sigmoid x},
          deriv1func: ->(x){
            s = sigmoid(x)
            s * (NMatrix.ones(x.shape) - s)
          },
        )
        net.load "#{ArchetypesPersistencePrefix}-#{format.id}"
        nets_by_formats[format.id] = net
      end
    end
    Misclassification.delete_all
    count=0
    correct_count=0
    deck_lists = DeckList.where.not(human_archetype_id: nil).joins(human_archetype: :format).where(formats: {enabled: true}).each do |dl|
      cids = dl.deck_entries.pluck(:card_id)
      format= dl.human_archetype.format_id
      net = nets_by_formats[format]
      cards= card_ids_by_format[format].map {|cid| cids.include?(cid) ? 1.0 : 0.0 }
      rowvec = NMatrix.new([1,cards.size], cards + [1.0])
      expected = dl.human_archetype_id
      actual, val = net.extract_class_from(net.evaluate_for(rowvec))
      count+=1
      if expected == actual
        correct_count+=1
        puts "https://firemind.ch/deck_lists/#{dl.id} - #{Archetype.find(expected)} #{val}".green if val < 0.7
      else
        puts "https://firemind.ch/deck_lists/#{dl.id} - #{Archetype.find(expected)} != #{Archetype.find(actual)} #{val}".red
        Misclassification.create(expected_id: expected, predicted_id: actual)
      end
    end
    puts "#{correct_count}/#{count}"

  end

  def print_errors(net, test, train)
    train_errors = []
    train_error_rate = train.map{|x|
      expected, val = net.extract_class_from(x[1])
      actual, val = net.extract_class_from(net.evaluate_for(x[0]))
      unless expected == actual
        train_errors << {expected: expected, actual: actual, val: val}
      end
      expected == actual ? 0.0 : 1.0
    }.inject(0, &:+)

    test_errors = []
    test_error_rate = test.map{|x| 
      expected, val = net.extract_class_from(x[1])
      actual, val = net.extract_class_from(net.evaluate_for(x[0]))
      if expected == actual
      else
        test_errors << {expected: expected, actual: actual, val: val}
      end
      expected == actual ? 0.0 : 1.0
    }.inject(0, &:+)


    puts "Train Error: #{train_error_rate / train.size}"
    puts "Test Error: #{test_error_rate / test.size}"
    return test_error_rate / test.size
  end
  task :reassign => :environment do
 
    DeckList.all.each_with_index do |dl, index|
      puts index if index%100 == 0
      a, val = NnArchetypeClient.send_query(dl)
      dl.archetype_score = val
      dl.archetype = a
      dl.save!
    end
    
  end
  task :tftest => :environment do
    client = TfArchetypeClient.new
    @head =nil
    count = 0
    correct = 0
    30.times do
      deck_lists = DeckList.where.not(human_archetype_id: nil).joins(human_archetype: :format).where(formats: {enabled: true}).order("rand()").limit(100).to_a
      client.query(deck_lists).each_with_index do |results, i|
        dl = deck_lists[i]
        predicted = results[:predicted]
        expected = dl.human_archetype
        count += 1
        if expected == predicted
          correct += 1
        else
          Misclassification.create(expected_id: expected.id, predicted_id: predicted.id, deck_list_id: dl.id)
          p "#{expected} != #{predicted}"
        end
      end
    end
    puts correct.to_f / count
  end
  task :tfupdate => :environment do
    @stub = Tensorflow::Serving::PredictionService::Stub.new('hub.firemind.ch:9000', :this_channel_is_insecure) #, :this_channel_is_insecure)
    skip=true
    @head =nil
    CSV.foreach("/mnt/fileshare/archetype-data/archetypes.csv") do |row|
      if skip
        skip=false
        @head = row[3..-1].map &:to_i
      else
        break
      end
    end
    Deck.joins(:format).where(formats: {enabled: true}).includes(:deck_list).find_in_batches(batch_size: 100) do |group|
      reqs = []
      group.each do |d|
        dl = d.deck_list
        cards = dl.deck_entries.pluck(:card_id)
        req = @head.map{|card| cards.include?(card) ? 1.0 : 0.0 }
        reqs << [req, dl]
      end
      tfpredict(reqs.map &:first).each_with_index do |predicted, i|
        dl = reqs[i][1]
        dl.archetype_id= predicted.to_i
        dl.save
      end
    end
  end

end
