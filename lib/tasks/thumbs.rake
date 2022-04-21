namespace :thumbs do
  task :missing => :environment do
    Card.joins(:card_prints).where(card_prints: {has_thumb:true}).having("count(card_prints.id) = 0").each do |card|
      puts card.name
    end
  end

  task :verify, [:edition_short] => :environment do |t, args|
    require 'colorize'

    prints = if s=args[:edition_short]
      CardPrint.joins(:edition).where(editions: {short: s})
    else
      CardPrint.all
    end

    progress_bar = ProgressBar.new(prints.count)
    prints.find_each(batch_size: 50) do |cp|

      edition = cp.edition
      edition_key = edition.short
      url = "#{THUMB_SERVER_URL}#{edition_key}/#{cp.nr_in_set}.jpg"
      res = FastImage.size(url)
      if res
        if res == [128,128]
          unless cp.has_thumb
            cp.has_thumb = true
            cp.save!
            puts "Enabling thumb on #{cp}".green
          end
        else
          puts "Wrong resolution #{cp} #{res} #{url}".yellow
        end
      else # not found
        if cp.has_thumb
          puts "Should have thumb but is missing #{cp} #{url}".red
          cp.has_thumb = false
          cp.save!
        else
          #puts "Has no thumb #{cp} #{url}".yellow
        end
      end
      progress_bar.increment
    end
  end

  task :archetype_calc, [:force] => :environment do |t, args|
    require 'colorize'
    scope = Archetype.joins(:format).where(formats: {enabled: true}).where.not(name: "No Archetype")
    progress_bar = ProgressBar.new(scope.count)
    scope.find_each(batch_size: 100) do |a|
      prev = a.thumb_print
      a.calculate_thumb
      if args[:force] || prev.nil? || prev.card == a.thumb_print.card
        a.save!
      elsif a.thumb_print != prev
        diff = if prev.card  != a.thumb_print.card
          "#{prev.card} (#{prev.edition.short}) to #{a.thumb_print.card} (#{a.thumb_print.edition.short})"
        else
          "#{prev.card} edition #{prev.edition.short} to #{a.thumb_print.edition.short}"
        end
        puts "Would change #{diff} for #{a} (#{a.format})".yellow
      end
      progress_bar.increment
    end
    puts "#{scope.where.not(thumb_print_id: nil).count}/#{scope.count}"
  end

  task :set_for_decks => :environment do 
    scope = Deck.where(thumb_print_id: nil)
    progress_bar = ProgressBar.new(scope.count)
    scope.find_each(batch_size: 500).each do |d|
      d.save(validate: false)
      progress_bar.increment
    end
  end

end

