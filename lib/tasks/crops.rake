namespace :crops do
  desc "Rename crop images"
  task :rename, [:name] => :environment do |t, args|
    raise "No name given" if args[:name].blank?
    e = Edition.where(short: args[:name] ).first!
    scan_root = "/mnt/fileshare/crops/#{e.short}"
    e.card_prints.each do |c|
      new_card_path = "#{scan_root}/#{c.nr_in_set}.jpg"
      next if File.exists? new_card_path
      card_path = nil
      %w(crop xrop).each do |type|
        next if File.exists?(card_path="#{scan_root}/#{Card.encode_cardname(c.name)}.#{type}.jpg")
        (1..5).each do |i|
          break(2) if File.exists?(card_path="#{scan_root}/#{Card.encode_cardname(c.name)}#{i}.#{type}.jpg")
        end
      end
      if File.exists?(card_path)
        cf = File.new(card_path)
        raise "Already there #{new_card_path}" if File.exists? new_card_path
        FileUtils.mv(cf.path, new_card_path)
      else
        puts "No file found for #{c.name} id #{c.nr_in_set}: #{card_path}"
      end
      if File.exists?(new_card_path)
        c.has_crop = true
        c.save!
      end
    end
  end
  desc "Check crop images"
  task :check, [:name] => :environment do |t, args|
    raise "No edition short given" if args[:name].blank?
    e = Edition.where(short: args[:name] ).first!
    scan_root = "/mnt/fileshare/crops/#{e.short}"
    e.card_prints.each do |c|
      new_card_path = "#{scan_root}/#{c.nr_in_set}.jpg"
      if File.exists?(new_card_path)
        unless c.has_crop
          puts "Enabling #{c.card.name}".green 
          c.has_crop = true
          c.save!
        end
      else
        if c.has_crop
          puts "Disabling #{c.card.name}".yellow
          c.has_crop = false
          c.save!
        end
      end
    end
  end
end
