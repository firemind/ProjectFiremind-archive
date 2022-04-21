namespace :scryfall do
  task :sync, [:name, :remote_name, :dryrun] => :environment do |t, args|
    require 'colorize'
    dryrun = !!args['dryrun']
    editions = if args[:name]
      remote_name = args[:remote_name] || args[:name]
      {
        args[:name].upcase => remote_name.upcase
      }
    else
       Edition.pluck(:short).map{|v| [v,v]}.to_h
    end
    if dryrun
      puts "DRYRUN"
    end

    client = ScryfallClient.new
    editions.collect do |setcode, remote_code|
      data = client.get_set(remote_code)
      raise "Got wrong code #{data['code']} != #{setcode}" unless data['code'].upcase == remote_code
      #res = File.read("mtgjson/#{mtgjsoncode}.json")
      ed = Edition.where(short: setcode).first_or_create!
      ed.name ||= data['name']
      ed.release_date = data['released_at']
      card_count = data['card_count']
      ed.save! unless dryrun
      flagged_prints =[]
      cards_data = client.cards_by_set(remote_code)
      progress_bar = ProgressBar.new(cards_data.count)
      p cards_data
      cards_data.reject{|r| ['plane', 'phenomenon','scheme'].include?(r['layout']) || r['type_line'] == "Conspiracy"}.group_by{|r|
        raise "Multiple multiverse ids not handled yet" if r['multiverse_ids'].size > 1
        r['multiverse_ids'].first
      }.map{|id, cards|
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
        card = Card.find_with_varying_name(card_data['name']) || Card.new(name: card_data['name'])
        puts "Card initialized for #{card.name}" unless card.id
        {
            card_type: :type_line,
            mana_cost: :manaCost,
            cmc: ->(r){ card_data['cmc'] || 0 },
            power: :power,
            toughness: :toughness,
            flip_name: :flip_name,
            creature_types: :subType,
            ability: :text,
            color: ->(r){(card_data['colors'] || []).join('').upcase},
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
        card.save! unless dryrun

        multiverse_id = card_data['multiverse_ids'].first
        if cp = card.card_prints.where(edition_id: ed.id, multiverse_id: multiverse_id ).first
        elsif cp = card.card_prints.where(edition_id: ed.id, multiverse_id: nil).first
          cp.multiverse_id = multiverse_id
        else
          cp = card.card_prints.build(edition_id: ed.id, multiverse_id: multiverse_id)
        end

        puts "New Card Print for #{card.name} in #{ed.short}" unless cp.id
        {
            nr_in_set: ->(r){
              v = r['collector_number']
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
        cp.save! unless dryrun
        flagged_prints << cp
        progress_bar.increment
      end
      ed.card_prints.where.not(id: flagged_prints.map(&:id)).each do |cp|
        if cp.card.card_prints.size > 1
          puts "Removing #{cp.card.name} from #{ed.name}"
          cp.destroy unless dryrun
        else
          card = cp.card
          cp.destroy unless dryrun
          card = card.reload
          puts "Removing card #{card.name}"
          unless dryrun
            unless card.destroy
              p card.errors
            end
          end
        end
      end
      ed.synced_at = Time.now
      ed.save! unless dryrun
    end
  end
end
