namespace :tools do

  desc "Enable Cards Available in Magarena"
  task :sync_magarena_cards => :environment do
    scripts_dir = '/usr/local/magarena/release/Magarena/scripts/'
    Dir.foreach(scripts_dir) do |item|
      next if item == '.' or item == '..' or item =~ /\.groovy$/ or item =~ /_token/
      cardname = File.open(scripts_dir+item) {|f| f.readline}.split('=')[1].chomp
      cards = Card.where(name: cardname)
      size = cards.size
      if size > 0
        card = cards.last
        if ! card.enabled
          card.enabled = true
          card.magarena_script = item
          card.added_in_next_release = false
          card.needs_groovy = false
          puts "Enabling #{cardname}"
          card.save!
          card.card_requests.each do |cr|
            cr.destroy
          end
        end
      else
        #card = Card.where("SOUNDEX(name) like SOUNDEX(?) ", cardname).first
        #if card
        #if Levenshtein.distance(card.name, cardname) < 3
        #card.enabled = true
        #card.magarena_script = item
        #card.save
        #if cr = CardRequest.where(card_id: card.id).first
        #cr.destroy
        #end
        #else
        #puts "False Match #{card.name} --- #{cardname}"
        #end
        #else
        puts "Not found #{size} #{cardname}"
        #end
      end
    end
  end
  desc "Enable Decks"
  task :enable_decks => :environment do
    Deck.joins(:deck_list).where(deck_lists: {enabled: false}).find_each do |deck|
      if deck.disabled_deck_entries.count == 0
        deck.enabled = true
        if deck.save
          puts "Enabling deck"
          deck.recalculate_formats
          DeckReportMailer.deck_enabled_email(deck).deliver
        else
          puts "Deck can't be saved #{deck.id}"
        end
      else
        #puts "Still not enabled #{deck.disabled_deck_entries.collect(&:card).join(", ")}"
      end
    end
  end

  # TODO: only used for initially filling the database, updates are handled via migrations and are not added to txt files
  task :read_restricted_lists => :environment do
    {vintage_banned: 'Vintage', modern_banned: 'Modern', legacy_banned: 'Legacy', pauper_banned: 'Pauper'}.each do |list, format_name|
      format = Format.where(name: format_name).first
      File.open("db/#{list}_list.txt").each do |line|
        card = Card.where(name: line.chomp).first
        if card
          rc = RestrictedCard.where(format_id: format.id, card_id: card.id).first_or_create!
          rc.limit = 0
          rc.save!
        else
          puts "Card #{line.chomp} not found"
        end
      end
    end
    {vintage_restricted: 'Vintage'}.each do |list, format_name|
      format = Format.where(name: format_name).first
      File.open("db/#{list}_list.txt").each do |line|
        card = Card.where(name: line.chomp).first
        if card
          rc = RestrictedCard.where(format_id: format.id, card_id: card.id).first_or_create!
          rc.limit = 1
          rc.save!
        else
          puts "Card #{line.chomp} not found"
        end
      end
    end
  end

  desc "Delete duels in formats the deck no longer has"
  task :remove_rotated_duels => :environment do
    formats = Format.where(name: %w(Standard Extended))
    formats.each do |f|
      f.decks.each do |deck|
        if deck.legal_in_format
          deck.duels.where.not(format_id: deck.format.id).destroy_all
        else
          deck.duels.destroy_all
        end
      end
    end
  end

  task :cleanup_duels=> :environment do
    Duel.all.find_each(batch_size: 200) do |duel|
      unless duel.scriptcheck? || (duel.deck_list1.legal_in?(duel.format) && duel.deck_list2.legal_in?(duel.format))
        Format.enabled.each do |f|
          if duel.deck_list1.legal_in?(f) && duel.deck_list2.legal_in?(f)
            duel.format = f
            duel.save!
            next
          end
        end
      end
    end
    Duel.all.find_each(batch_size: 200) do |duel|
      unless duel.scriptcheck? || (duel.deck_list1.legal_in?(duel.format) && duel.deck_list2.legal_in?(duel.format))
        duel.destroy
      end
    end
  end

  task :clean_up_ratings => :environment do
    Rating.all.find_each(batch_size: 200) do |rating|
      unless rating.deck.legal_in_format and !rating.deck.legality_out_of_date and rating.deck.format == rating.format
        puts "Destroying rating for #{rating.deck} #{rating.format}"
        rating.destroy
      end
    end
  end

  task :update_cards_from_mtgdb => :environment do
    uri = URI.parse("http://api.mtgdb.info/sets/")
    begin
      request = Net::HTTP.get_response(uri)
    rescue Exception => e
      ::Rails.logger.error "!!! uri:: #{uri.inspect}\n"
      raise e
    end

    # Initialize objects for returned formats
    #JSON.parse(request.body).collect { |set|
    [{'name' => "Magic Origins", 'id' => "ORI"}].collect { |set|
      ed = Edition.where(name: set['name']).first
      if ed
        uri = URI.parse("http://api.mtgdb.info/sets/#{set['id']}/cards")
        request = Net::HTTP.get_response(uri)
        cards_data = JSON.parse(request.body)
        cards_data.each do |card_data|
          next if card_data['token']
          card = Card.where(name: card_data['name'].gsub(/AE/, 'Æ').gsub("Jotun", "Jötun")).first
          unless card
            puts "Card not found: #{card_data['name']}"
            card = Card.new
            card.name = card_data['name']
            card.card_type = card_data['type']
            card.mana_cost = card_data['manacost']
            card.cmc = card_data['convertedManaCost'].to_i
            card.power = card_data['power']
            card.toughness = card_data['toughness']
            card.creature_types = card_data['subType']
            card.ability = card_data['description']
            card.color = card_data['colors'].join('').gsub("None",'').gsub("black",'B').gsub("red",'R').gsub("green",'G').gsub("white",'W').gsub("blue",'U')
            card.loyalty = card_data['loyalty']
            card.back_id = card_data['relatedCardId']
          end
          card.save!
          cp = card.card_prints.where(edition_id: ed.id).first
          if cp
            cp.nr_in_set = card_data['number']
            cp.multiverse_id = card_data['id']
            cp.save
          else
            puts "Card print not found #{card_data['name']} in #{ed.id}"
            cp = CardPrint.new
            cp.card = card
            cp.edition = ed

            card_data['rarity'] = "Common" if card_data['rarity'] == "Basic Land"
            card_data['rarity'] = "Common" if card_data['rarity'] == "Bonus"
            card_data['rarity'] = "Mythic" if card_data['rarity'] == "Mythic Rare"
            cp.rarity = card_data['rarity'].downcase.to_sym
            puts card_data['rarity'] unless ['rare','common','uncommon','mythic','timeshifted'].include? card_data['rarity'].downcase

            #cp.flavor_text = card_data['flavor']
            cp.artist = card_data['artist']
            cp.save!
          end
        end
      else
        puts "Set not found #{set['name']}"
        ed = Edition.new
        ed.name = set['name']
        ed.short = set['id']
        ed.save
      end
    }
  end




  task :populate_airms => :environment do
    AirmDeck.delete_all
    # readd 7445 once reanimator bug is fixed https://github.com/magarena/magarena/issues/110
    deck_list_ids = [1863, 5841, 87, 4439, 615, 537, 7427, 7361, 7429, 1303, 7399, 7359, 643, 291, 293, 7297, 7321,407, 71,1303, 567].uniq.sort
    deck_list_ids.combination(2).each do |dl_ids|
      d1= dl_ids[0]
      d2= dl_ids[1]
      unless AirmDeck.where("(deck_list1_id = ? and deck_list2_id = ?) or (deck_list1_id = ? and deck_list2_id = ?)", d1, d2, d2, d1).any?
        AirmDeck.create(deck_list1_id: d1, deck_list2_id: d2, rounds: 1)
      end
    end

  end

  task :deal_hands => :environment do
    deck_lists = [1863, 5841, 319, 1129, 1303, 2223]
    DeckList.where(id: deck_lists).includes(:deck_entries).each do |dl|
      deck = []
      dl.deck_entries.each do |de|
        de.amount.times do
          deck << de.card_id
        end
      end
      50.times do
        (3..6).each do |hand_size|
          hand = deck.sample(hand_size)
          dh = DealtHand.create(deck_list_id: dl.id)
          hand.each do |card|
            DealtCard.create(
              dealt_hand_id: dh.id,
              card_id: card
            )
          end
        end
      end
    end
  end

  task :test_pio => :environment do
    # Create PredictionIO event client.


#    client = PredictionIO::EngineClient.new('http://62.12.149.34:8000')
#    response = client.send_query(user: [123], num: 1)
  end

  task :feed_deck_lists => :environment do

    client = PioClient.new
    DeckList.order("RAND()").first(1000).each do |dl|
      at = dl.archetype
      next unless at
      #if at
        #dirname ="deck_lists/#{at.id}/"
        #unless File.directory?(dirname)
          #FileUtils.mkdir_p(dirname)
        #end
        #outputfile = "#{dirname}/#{dl.id}.dec"
        #File.open(outputfile, 'w') { |file|
          #file.write(dl.as_text)
        #}
      text = []
      dl.deck_entries.each do |de|
        de.amount.times { text << "#{de.card_id}" }
      end
      client.create_event(
        'archetype-entry',
        'decklist',
        dl.id, {
          'properties' => {
            'entries' => dl.deck_entries.map{|r| [r.card_id, r.amount]},
            'category' => at.id,
          }
        }
      )
    end
  end

  task :feed_manual_decks => :environment do

    client = PioClient.new
    DeckList.where("human_archetype_id is not null").each do |dl|
      at = dl.human_archetype
      next unless at
      #if at
        #dirname ="deck_lists/#{at.id}/"
        #unless File.directory?(dirname)
          #FileUtils.mkdir_p(dirname)
        #end
        #outputfile = "#{dirname}/#{dl.id}.dec"
        #File.open(outputfile, 'w') { |file|
          #file.write(dl.as_text)
        #}
      text = []
      dl.deck_entries.each do |de|
        de.amount.times { text << "#{de.card_id}" }
      end
      client.create_event(
        'archetype-entry',
        'decklist',
        dl.id, {
          'properties' => {
            'entries' => dl.deck_entries.map{|r| [r.card_id, r.amount]},
            'category' => at.id,
            'format_id' => at.format_id,
          }
        }
      )
    end
  end


  task :test_pio => :environment do

    wrong_count = 0
    count = 0
    ActiveRecord::Base.uncached() do
      DeckList.where.not(human_archetype_id: nil).order("RAND()").first(100).each do |dl|
        next unless dl.archetype
        client = PioArchetypeClient.new
        response = client.request_decklist(dl, dl.archetype.format_id)
        archetype = dl.human_archetype || dl.archetype
        score = response['score']
        next if response['p'].to_i == 0
        if response['p'].to_i != archetype.id
          wrong_count +=1
          puts "expected #{archetype} got #{Archetype.find(response['p'].to_i)} #{dl.id} score:#{score}"
        else
          puts "found match with score:#{score}" if score < 20
        end
        count+=1
      end
    end
    puts "#{wrong_count}/#{count} wrong"
  end

  task :fetch_pio => :environment do
    access_key = 'WCkxSZgysqcIcjLO2a5FcMzspYFSq3riB8opymdbi5oc8kLLfb0UqTrQ1CXAKWdS'
    url = PioArchetypeClient.url
    pio_threads = 50
    puts `curl -i -X GET "#{url}/events.json?accessKey=#{access_key}"`
  end

  task :rotate_standard_decks => :environment do
    standard = Format.standard
    modern = Format.modern
    legacy = Format.legacy
    standard.decks.each do |deck|
      unless deck.deck_list.legal_in? standard
        puts "Deck not legal"
        deck.format =  deck.deck_list.legal_in?(modern) ? modern : legacy
        deck.save!
      end
    end
  end

  task :primitive_sideboard_calc => :environment do
    @deck = Deck.find 159692
    @inputs  = {}
    @outputs = {}
    @cards = []
    @matchups = []
    @sideboard_options = {}
    @deck.sideboard_plans.each do |sp|
      @matchups |= [sp.archetype.id]
      ins = {}
      sp.sideboard_ins.each do |si|
        ins[si.card.id] = si.amount
        @cards |= [si.card.id]
        @sideboard_options[si.card.id] ||= 0
        @sideboard_options[si.card.id] = si.amount if @sideboard_options[si.card.id] < si.amount
      end
      @inputs[sp.archetype.id] = ins

      @outputs[sp.archetype.id] = sp.sideboard_outs.sum(:amount)
    end
    @sideboard_pool = []
    @sideboard_options.each {|key, val| val.times{ @sideboard_pool << key}}

    @sideboard_size = 15

    best_sideboard = nil
    best_score = 10000000
    combs = @sideboard_pool.combination(@sideboard_size)
    total_size = combs.size
    puts "total_size #{total_size}"
    combs.each_with_index do |sb, index|
      puts "#{index.to_f * 100 / total_size}% done score:#{best_score}" if index % 1000000 == 0
      grouped_sb = sb.each_with_object(Hash.new(0)) { |card,counts| counts[card] += 1 }
      score = score_sideboard_option grouped_sb
      if score < best_score
        best_score = score
        best_sideboard = grouped_sb
      end
    end

    @winner = best_sideboard
    puts @winner.inspect

  end

  task :genetic_sideboard_calc => :environment do
    deck = Deck.find 159692
    worker = GeneticSideboardWorker.new
    worker.perform(deck.id, 2)
    #worker.perform(deck.id)
  end


  def print_sideboard(sideboard)
    sideboard.each do |card_id, amount|
      puts "#{amount} #{Card.find card_id}"
    end
  end


  task :update_archetype_assignments=> :environment do
    DeckList.all.find_each(batch_size: 100){|dl|
      AssignArchetypeWorker.new.perform(dl.id)
    }
  end
  
  task :fix_archetype_formats => :environment do
    format_hierarchy = [
      :pauper,
      :standard,
      :modern,
      :legacy,
      :vintage
    ].map{|s| Format.send s }
    DeckList.find_each(batch_size: 200) do |d|
      FormatCalcWorker.new.perform d.id
      format_hierarchy.each do |f|
        if d.legal_in? f
          if d.human_archetype
            new_human_archetype = Archetype.where(name: d.human_archetype.name, format_id: f.id).first
            if new_human_archetype && new_human_archetype != d.human_archetype
              puts "Would change human archetype of #{d.id} from #{d.human_archetype} to #{new_human_archetype} "
              puts "#{d.human_archetype.format} to #{new_human_archetype.format}"
              d.human_archetype = new_human_archetype
            end 
          end
          if d.archetype
            new_archetype = Archetype.where(name: d.archetype.name, format_id: f.id).first
            if new_archetype && new_archetype != d.archetype
              puts "Would change archetype of #{d.id} from #{d.archetype} to #{new_archetype}"
              puts "#{d.archetype.format} to #{new_archetype.format}"
              d.archetype = new_archetype
            end
          end
          d.save!
          break
        end
      end
    end 
  end
  task :fix_deck_formats => :environment do
    Deck.where.not(format_id: Format.enabled.pluck(:id)).find_each(batch_size: 50) do |d|
      possible_format = Format.where(format_type: d.format.format_type, enabled: true).first
      FormatCalcWorker.new.perform d.deck_list_id #if d.deck_list.formats.size == 0
      if d.deck_list.legal_in? possible_format
        d.format = possible_format
        d.save(validate: false)
      end
    end
  end

  task :test_push => :environment do
    User.find(49).duels.last.inform_success
  end

  task :sync_missing_needs_groovy => :environment do
    scripts_dir =  Rails.configuration.x.magarena_tracking_repo+"/release/Magarena/scripts_missing/"
    Dir.foreach(scripts_dir) do |item|
      next if item == '.' or item == '..' or item =~ /\.groovy$/ or item =~ /_token/

      content = File.read("#{scripts_dir}/#{item}").split("\n")
      cardname = content.first.split('=')[1].chomp
      card = Card.find_with_varying_name(cardname)
      unless card
        raise "Card not found #{cardname}"
      end
      next if card.needs_groovy

      if needs_groovy_line = content.select {|l| l =~ /^status=needs groovy/ }.first
        puts "Adding to #{card}"
        card.needs_groovy = true
        card.save!
      end
    end
  end
  task :sync_upcoming_cards => :environment do
    scripts_dir =  Rails.configuration.x.magarena_tracking_repo+"/release/Magarena/scripts/"
    Dir.foreach(scripts_dir) do |item|
      next if item == '.' or item == '..' or item =~ /\.groovy$/ or item =~ /_token/ or item =~ /;Morph/
      puts item
      content = File.read("#{scripts_dir}/#{item}").split("\n")
      cardname = content.first.split('=')[1].chomp
      card = Card.find_with_varying_name(cardname)
      unless card
        raise "Card not found #{cardname}"
      end
      next if card.enabled

      puts "Adding to #{card}"
      card.added_in_next_release = true
      card.save!

    end
  end

  task :recalc_archetype_with_low_score => :environment do
    Format.enabled.each do |f|
      f.deck_lists.where(human_archetype_id: nil).where("archetype_score < ?", MIN_ARCHETYPE_SCORE).each do |dl|
        AssignArchetypeWorker.new.perform(dl.id)
      end
    end
  end
  task :archetype_switch_if_card, [:archetype_old_id, :archetype_new_id, :card] => [:environment] do |t, args|
    card = Card.find_with_varying_name(args[:card])
    archetype_old = Archetype.find args[:archetype_old_id]
    archetype_new = Archetype.find args[:archetype_new_id]
    puts "Swiching all decks in archetype #{archetype_old} to #{archetype_new} if they contain #{card}"
    archetype_old.deck_lists.containing_card(card.id).each do |dl|
      dl.archetype = archetype_new
      dl.human_archetype = archetype_new
      dl.save!
    end


  end
   
  task :list_aftermath => :environment do
    Edition.where(short: [:AKH, :HOU]).each do |ed|
      scan_root = "/var/www/static/thumbs/#{ed.short}"
      ed.card_prints.each do |cp|
        card = cp.card
        if card.name.include?('//')
          path = "#{scan_root}/#{cp.nr_in_set}.jpg"
          puts "rm -f #{path}"
        end
      end
    end
  end

end

