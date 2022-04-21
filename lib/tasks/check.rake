namespace :check do
  task :changed_udi => :environment do
    scope = DeckList
    progress_bar = ProgressBar.new(scope.count)
    scope.find_each(batch_size: 100) do |dl|
      old_udi = dl.udi
      new_udi = dl.calculate_udi
      if old_udi != new_udi
        puts "DeckList #{dl.id}: #{old_udi} != #{new_udi}"
        other = DeckList.where(udi: new_udi).first
        if other
          dl.decks.each do |d|
            d.deck_list = other
            d.save!
          end
          dl.destroy
        else
          dl.udi = new_udi
          dl.save!
        end
      end
      progress_bar.increment
    end
  end
  task :wrong_enabled => :environment do
    scope = DeckList
    progress_bar = ProgressBar.new(scope.count)
    scope.find_each(batch_size: 100) do |dl|

      old = dl.enabled
      dl.set_enabled
      if old != dl.enabled
        puts "Changed: #{dl.id}"
        dl.save(validate: false)
      end
      progress_bar.increment
    end
  end
  task :nowhere_legal => :environment do
    ids = DeckList.nowhere_legal.pluck(:id)
    progress_bar = ProgressBar.new(ids.size)
    ids.each do |id|
      FormatCalcWorker.new.perform id
      progress_bar.increment
    end
  end
  task :archetype_banners => :environment do
    include ArchetypeHelper
    Archetype.joins(:format).where(formats: {enabled: true}).each do |archetype|
      path = banner_url(archetype)
      url = URI.parse(path)
      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = true
      res = http.get(url.request_uri)
      if res.code.to_i == 404
        if archetype.has_banner
          archetype.has_banner = false
          puts "Disabling #{archetype} #{url.request_uri}".yellow
        end
      else
        unless  archetype.has_banner
          archetype.has_banner = true
          puts "Enabling #{archetype}".green
        end
      end
      archetype.save
    end
  end

  task :no_prints => :environment do
    Card.all.each do |c|
      puts c.inspect if c.card_prints.empty?
    end
  end

  task :no_image_prints => :environment do
    require 'colorize'
    Card.where(primary_print_id: nil).each do |c|
      if c.primary_print =  c.card_prints.where(with_image: true).order("created_at desc").first
        c.save!
        puts c.name.green
      else
        if c.enabled
          puts c.name.red
        else
          puts c.name.yellow
        end
      end
    end
  end

  task :duplicate_numbers => :environment do
    Edition.all.each do |e|
      e.card_prints.group_by(&:nr_in_set).each do |num, cards|
        if cards.size > 1
          puts "#{num} #{e} #{cards.map{|r| "#{r.name} #{r.id}"}}"
        end
      end
    end
  end

  task :entry_without_list => :environment do
    DeckEntry.find_each(batch_size: 100) do |de|
      unless de.deck_list
        d = Deck.where(deck_list_id: de.deck_list_id).first
        p d
        de.destroy
      end
    end
  end

  task :archetype_format_mismatch => :environment do
    require 'colorize'
    dls = DeckList.joins(:decks, :archetype).where("decks.format_id != archetypes.format_id")
    progress_bar = ProgressBar.new(dls.size)
    dls.each do |dl|
      unless dl.decks.any?{|d| d.format.enabled}
        text = "#{dl.id} #{dl.archetype} #{dl.archetype.format} != #{dl.decks.map(&:format).join(",")}"
        if dl.human_archetype
          if dl.decks.map(&:format_id).include? dl.human_archetype.format_id
            dl.archetype = dl.human_archetype
            puts text.green
          else
            f =dl.decks.joins(:format).where(formats: {enabled: false}).first.format
            at = f.archetypes.where(name: dl.human_archetype.name).first_or_create
            dl.archetype = at
            dl.human_archetype = at
            puts "Moving #{at.name} to #{f}".yellow
          end
        else
          dl.archetype = dl.decks.first.format.no_archetype
          puts text.red
        end
        dl.save!
      end
      progress_bar.increment
    end
  end
  task :pauper_legality => :environment do
    card_ids = CardPrint.where(rarity: :common).pluck(:card_id).uniq
    Format.where(format_type: :pauper).each do |format|
      before = format.legal_cards.count
      format.legalities = Card.full_binary(Card.card_ids_at(format.legalities.to_i) & card_ids)
      format.save!
      puts "Deleted #{before-format.legal_cards.count} legalities from #{format}"
    end
  end
end

