namespace :legalities do
  task :recalc, [:name] => :environment do |t, args|
    require 'colorize'
    if args[:name].blank?
      formats = Format.where.not(format_type:nil)
    else
      formats = Format.where(name: args[:name] )
    end
    progress_bar = ProgressBar.new(formats.count)
    formats.each do |format|
      legal_before = format.legal_cards
      card_ids = format.editions.inject([]) { |ids, ed|
        if format.format_type.to_s.downcase == 'pauper'
          ids |= ed.card_prints.where(rarity: 'common').pluck(:card_id)
        else
          ids |= ed.card_prints.pluck(:card_id)
        end
      }
      card_ids -= format.restricted_cards.where(limit: 0).pluck :card_id
      format.legalities = Card.full_binary(card_ids)
      if format.legalities_was.to_s != format.legalities.to_s
        #puts format.legalities_was.to_s.red
        #puts format.legalities.to_s.green
        legal_now = format.legal_cards
        puts "=== #{format} ==="
        if (no_longer_legal =legal_before -legal_now).any?
          puts "=== No longer legal #{no_longer_legal.size} ==="
          no_longer_legal.first(5).each do |c|
            puts c.name
          end
        end
        if (now_legal =legal_now-legal_before).any?
          puts "=== Now legal #{now_legal.size} ==="
          now_legal.first(5).each do |c|
            puts c.name
          end
        end
      end
      format.save!
    end
  end
  task :calc_deck_lists, [:name]  => :environment do |t,args|
    require 'colorize'
    unless args[:name].blank?
      format = Format.where(name: args[:name] ).first!
      scope = format.deck_lists
    else 
      scope = DeckList.all
    end

    progress_bar = ProgressBar.new(scope.count)
    scope.find_each(batch_size: 50).each do |dl|
      before = dl.formats.pluck :id
      FormatCalcWorker.new.process_dl dl, nolog: true
      dl.formats.reset
      after = dl.formats.pluck :id
      if before != after
        puts "#{(before-after).sort.to_s.red} => #{(after-before).sort.to_s.green}"
      end
      progress_bar.increment
    end
  end
  task :calc_by_deck, [:name]  => :environment do |t,args|
    require 'colorize'
    unless args[:name].blank?
      format = Format.where(name: args[:name] ).first!
      scope = format.decks
    else 
      scope = Deck.all
    end

    progress_bar = ProgressBar.new(scope.count)
    scope.find_each(batch_size: 50).each do |deck|
      dl = deck.deck_list
      before = dl.formats.pluck :id
      FormatCalcWorker.new.process_dl dl, nolog: true
      dl.formats.reset
      after = dl.formats.pluck :id
      if before != after
        puts "#{(before-after).sort.to_s.red} => #{(after-before).sort.to_s.green}"
      end
      progress_bar.increment
    end
  end
  task :add_set, [:short] => :environment do |t, args|
    edition = Edition.where short: args[:short]
    %w(pauper vintage legacy).each do |format|
      f = Format.where(name: format).first
      f.editions << edition
      f.save!
    end
  end
  task :check_duels, [:name]  => :environment do |t,args|
    require 'colorize'
    unless args[:name].blank?
      format = Format.where(name: args[:name] ).first!
      scope = format.duels
    else 
      scope = Duel.all
    end
    progress_bar = ProgressBar.new(scope.count)
    scope.find_each(batch_size: 50).each do |duel|
      if duel.deck_list1.legal_in?(duel.format) && duel.deck_list1.legal_in?(duel.format)
      elsif duel.deck_list1.legal_in?(Format.vintage) && duel.deck_list1.legal_in?(Format.vintage)
        duel.format = Format.vintage
        duel.save!
        puts "changed to Vintage #{duel.id}"
      else
        duel.format = nil
        duel.freeform = true
        duel.save!
        puts "changed to Freeform #{duel.id}"
      end
      progress_bar.increment
    end
    
  end


end
