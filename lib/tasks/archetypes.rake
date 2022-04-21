namespace :archetypes do
  task :export => :environment do
    basedir= Rails.configuration.x.archetype_model_path
    exportfile = "archetypes.csv"
    FileUtils.mkdir_p basedir
    #deck_lists = DeckList.where.not(human_archetype_id: nil)
    deck_lists = DeckList.where.not(human_archetype_id: nil).joins(human_archetype: :format).where(formats: {enabled: true}) #.joins(:human_archetype).where(archetypes: {format_id: Format.modern.id})
    card_ids = DeckEntry.where("deck_list_id in (#{deck_lists.select(:id).to_sql})" ).pluck(:card_id).uniq
    CSV.open(File.join(basedir, exportfile), "w") do |csv|
      header_row = card_ids.dup
      header_row.insert(0, "deck_list_id")
      header_row.insert(1, "archetype")
      header_row.insert(2, "format")
      csv << header_row
      deck_lists.each do |dl|
        entries = {}
        #dl.deck_entries.each {|de| entries[de.card_id] = [1,de.amount].min}
        #row = card_ids.map{|cid| entries[cid] || 0}
        row = dl.deck_entries.pluck(:card_id)
        row.insert(0, dl.id)
        row.insert(1, dl.human_archetype_id)
        row.insert(2, dl.human_archetype.format_id)
        csv << row
      end
    end
    CSV.open("archetype_names.csv", "w") do |csv|
      header_row = ['archetype_id', 'archetype_name']
      csv << header_row
      Archetype.all.each do |at|
        row = [at.id, at.to_s]
        csv << row
      end
    end
  end
  task :verify, [:format] => :environment do |t, args|
    require 'colorize'
    scope = if args[:format]
      Format.where(name: args[:format]).first!.decks
    else
      Deck.joins(:format).where(formats: {enabled: true})
    end

    client = TfArchetypeClient.new

    Misclassification.delete_all

    num = scope.count
    num_misclass = 0
    total_labled = 0
    progress_bar = ProgressBar.new(scope.count)
    scope.includes(deck_list: :human_archetype).find_in_batches(batch_size: 200) do |decks|
      deck_lists = decks.map &:deck_list
      client.query(deck_lists).each_with_index do |results, i|
        dl = deck_lists[i]
        predicted = results[:predicted]
        if predicted.nil?
          puts "Nothing predicted #{results.inspect}".red
          next
        end
        if expected = dl.human_archetype
          total_labled += 1
          if dl.archetype != dl.human_archetype
            dl.archetype = dl.human_archetype
            dl.save!
          end
          if expected && predicted && (expected != predicted)
            num_misclass += 1
            Misclassification.create(expected_id: expected.id, predicted_id: predicted.id, deck_list_id: dl.id)
            puts "#{expected} != #{predicted}".red
          end
        else
          dl.archetype_score = results[:score]
          a = predicted
          if dl.archetype_score < MIN_ARCHETYPE_SCORE || !(in_format=dl.formats.include?(a.format))
            puts "Setting no archetype because score is #{dl.archetype_score}" if dl.archetype_score < MIN_ARCHETYPE_SCORE
            dl.archetype = if in_format
              a.format.no_archetype
            elsif f = ( (d = dl.decks.first) && dl.formats.include?(d.format) && d.format) || dl.formats.enabled.first
              f.no_archetype
            else
              vintage = Format.vintage
              dl.formats.include?(vintage) ? vintage.no_archetype : nil
            end
            puts "Setting archetype to #{dl.archetype}".yellow if dl.archetype_id_changed?
          else
            if dl.archetype != predicted
              if dl.archetype
                puts "Updating archetype from #{dl.archetype} to #{predicted}".yellow
              else
                puts "Setting archetype to #{predicted}".green
              end
              dl.archetype = predicted
            end
          end
          dl.save!
        end
      end
      progress_bar.increment(deck_lists.size)
    end
    puts "done"
    puts "#{num_misclass.to_f/total_labled} of labeld data wrong"

  end
  task :reclassify_noarchetype => :environment do |t, args|
    Archetype.where(name: "No Archetype").joins(:format).where(formats: {enabled: true}).each do |at|
      puts "#{at.name} #{at.format}"
      client = TfArchetypeClient.new
      scope = at.deck_lists
      progress_bar = ProgressBar.new(scope.size)
      updated_count = 0
      scope.find_in_batches(batch_size: 200).each do |deck_lists|
        client.query(deck_lists).each_with_index do |results, i|
          predicted = results[:predicted]
          next unless predicted
          dl = deck_lists[i]
          dl.archetype_score = results[:score]
          if dl.archetype_score < MIN_ARCHETYPE_SCORE
            puts "Score too low #{dl.archetype_score}"
          elsif !(in_format=dl.formats.include?(predicted.format))
            puts "Not in format #{predicted.format} #{dl.formats.pluck(:name).inspect}"
          else
            dl.archetype = predicted
            dl.save!
            updated_count +=1
          end
          progress_bar.increment
        end
      end
      puts "#{updated_count}/#{scope.size} updated"
    end
  end
end
