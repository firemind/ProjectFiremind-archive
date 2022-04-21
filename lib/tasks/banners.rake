namespace :banners do
  task :print_script => :environment do |t, args|
    all_missing = []
    Archetype.joins(:format).where(formats: {enabled: true}).each do |archetype|
      deck_entries = DeckEntry.joins(:deck_list).where(deck_lists: {human_archetype_id: archetype.id}).where.not(card_id: Card.basics.pluck(:id)).select("card_id, sum(amount) as copy_count, count(deck_list_id) as dl_count, group_type").group("card_id, group_type").includes(:card)

      deck_lists = archetype.human_deck_lists
      dl_count = deck_lists.count
      next if dl_count == 0
      cards = deck_entries.sort_by{|de| 
        number_of_copies_per_deck= de.copy_count.to_f / de.dl_count
        percent_of_decks= de.dl_count.to_f / dl_count
        occurence_in_others = DeckEntry.joins(:deck_list).where(card_id: de.card_id).
          where.not(deck_lists: {human_archetype_id: archetype.id}).
          select("sum(amount)/count(deck_entries.id) as occ").first.occ || 0
        factor = de.group_type== 'lands' ? 0.7 : 1
        (number_of_copies_per_deck/4 + percent_of_decks - occurence_in_others/4/10)*factor
      }.reverse
      crops = []
      missing = []
      cards.each do |c|
        cp = c.card.card_prints.where(has_crop: true).sort_by{|cp| cp.edition.short[0..2] == "MPS" ? 0 : 1 }.last
        if cp
          crops << cp
          break if crops.size == 6
        else
          missing << "CP crop missing for #{c.card}"
        end
      end
      if crops.size == 6
        puts "/root/mtg-banner-generator/merge.sh #{archetype.id} #{crops.map{|r| "#{r.edition.short}/#{r.nr_in_set}"}.join(' ')}"
      else
        STDERR.puts "Missing for #{archetype} #{archetype.id}. Candidates are:"
        missing.each do |m|
          STDERR.puts m
        end
        all_missing += missing
      end
    end
    all_missing.group_by{|i| i}.map{|k,v| [v.count, k] }.sort_by{|r| r[0]}.reverse.each do |e|
      STDERR.puts e.inspect
    end
  end

end
