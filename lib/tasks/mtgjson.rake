namespace :mtgjson do
  task :sync, [:name, :remote_name] => :environment do |t, args|
    require 'colorize'
    editions = if args[:name]
      remote_name = args[:remote_name] || args[:name]
      {
        args[:name] => remote_name
      }
    else
       Edition.pluck(:short).map{|v| [v,v]}.to_h
    end

    progress_bar = ProgressBar.new(editions.count)
    editions.collect do |setcode, mtgjsoncode|
      next if setcode == "BOK" # https://github.com/mtgjson/mtgjson/issues/388
      uri = URI.parse("https://mtgjson.com/json/#{mtgjsoncode}.json")
      puts uri
      request = Net::HTTP.get_response(uri)
      res = request.body
      #res = File.read("mtgjson/#{mtgjsoncode}.json")
      ed = Edition.where(short: setcode).first_or_create!
      data = JSON.parse(res)
      ed.name ||= data['name']
      ed.release_date = data['releaseDate']
      ed.save!
      flagged_prints =[]
      cards_data = data['cards']
      cards_data.reject{|r| ['plane', 'phenomenon','scheme'].include?(r['layout']) || r['type'] == "Conspiracy"}.group_by{|r| (r['multiverseid']&.to_i||r['mciNumber']&.to_i||r['number']) }.map{|id, cards|
        if cards.size > 1
          if ['split', 'aftermath'].include? cards[0]['layout']
            c = cards[0]
            c['name'] += " // " + cards[1]['name']
            c['text'] += "\n//\n" + cards[1]['text']
            c
          elsif ['flip','double-faced', 'meld', 'aftermath'].include? cards[0]['layout']
            if cards[0]['number'][-1] == 'a'
              c1 = cards[0]
              c2 = cards[1]
            elsif cards[1]['number'][-1] == 'a'
              c1 = cards[1]
              c2 = cards[0]
            else
              puts "Can't find primary from number #{id} #{JSON.pretty_generate(cards)}".red
              next nil
            end
            c1['name']
            c1['flip_name'] = c2['name']
            c1['text'] += "\n//\n" + c2['text']
            c1
          else
            raise "Double multiverse id #{id} without split #{JSON.pretty_generate(cards)}"
          end
        else
          cards[0]
        end
      }.compact.each do |card_data|
        next if card_data['layout'] == 'token'
        name = card_data['name'].gsub(/(\ \((a|b)\))/, '')
        card = Card.find_with_varying_name(name) || Card.new(name: name)
        puts "Card initialized for #{card.name}" unless card.id
        {
            card_type: :type,
            mana_cost: :manaCost,
            cmc: ->(r){ card_data['cmc'] || 0 },
            power: :power,
            toughness: :toughness,
            flip_name: :flip_name,
            creature_types: :subType,
            ability: :text,
            color: ->(r){(card_data['colors'] || []).join('').gsub("None",'').downcase.gsub("black",'B').gsub("red",'R').gsub("green",'G').gsub("white",'W').gsub("blue",'U')},
            loyalty: :loyalty,
            back_id: :relatedCardId,
        }.each do |int_attr, ext_attr|
          val = if ext_attr.is_a? Proc
                  ext_attr.call(card_data)
                else
                  card_data[ext_attr.to_s]
                end
          unless val.nil?
            card.send "#{int_attr}=", val
            if card.send "#{int_attr}_changed?"
              orig = card.send("#{int_attr}_was")
              if orig.blank? && !val.blank?
                puts "#{card.name}.#{int_attr} set to #{val}".green
              elsif !orig.blank? && val.blank?
                puts "#{card.name}.#{int_attr} removed (was #{orig})".red
              elsif val.to_s.size < 5
                puts "Changing #{card.name}.#{int_attr} from #{orig.to_s.red} to #{val.to_s.green}"
              else
                puts "Changing #{card.name}.#{int_attr}"
                puts Diffy::Diff.new orig, val, format: :color
              end
            end
          end
        end
        card.save!

        if cp = card.card_prints.where(edition_id: ed.id, multiverse_id: card_data['multiverseid']).first
        elsif cp = card.card_prints.where(edition_id: ed.id, multiverse_id: nil).first
          cp.multiverse_id = card_data['multiverseid']
        else
          cp = card.card_prints.build(edition_id: ed.id, multiverse_id: card_data['multiverseid'])
        end

        puts "New Card Print for #{card.name} in #{ed.short}" unless cp.id
        {
            nr_in_set: ->(r){
              v = r['mciNumber'] || r['number']
              if v.nil?
                nil
              elsif v[0..5] =~ /\de\/en\//
                v[6..-1]
              elsif v.to_i > 0
                if r['layout'] == 'split'
                  v.to_i
                else
                  v
                end
              else
                nil
              end
            },
            rarity: ->(r){
              v = r['rarity']
              v = "Common" if v == "Basic Land"
              v = "Common" if v == "Bonus"
              v = "Timeshifted" if v == "Special" && r['timeshifted']
              v = "Mythic" if v == "Mythic Rare"
              v.downcase.to_sym
            },
            artist: :artist

        }.each do |int_attr, ext_attr|
          val = if ext_attr.is_a? Proc
                  ext_attr.call(card_data)
                else
                  card_data[ext_attr.to_s]
                end
          unless val.nil?
            cp.send "#{int_attr}=", val
            if cp.send "#{int_attr}_changed?"
              orig = cp.send("#{int_attr}_was")
              if orig.blank? && !val.blank?
                puts "#{cp.name}.#{int_attr} set to #{val}".green
              elsif !orig.blank? && val.blank?
                puts "#{cp.name}.#{int_attr} removed (was #{orig})".red
              elsif val.to_s.size < 5
                puts "Changing #{cp.name}.#{int_attr} from #{orig.to_s.red} to #{val.to_s.green}"
              else
                puts "Changing #{cp.name}.#{int_attr}"
                puts Diffy::Diff.new orig, val, format: :color
              end
            end
          end
        end
        cp.save!
        flagged_prints << cp
      end
      ed.card_prints.where.not(id: flagged_prints.map(&:id)).each do |cp|
        if cp.card.card_prints.size > 1
          puts "Removing #{cp.card.name} from #{ed.name}"
          cp.destroy
        else
          card = cp.card
          cp.destroy
          card = card.reload
          puts "Removing card #{card.name}"
          unless card.destroy
            p card.errors
          end
        end
      end
      ed.synced_at = Time.now
      ed.save!
      progress_bar.increment
    end
  end
end
