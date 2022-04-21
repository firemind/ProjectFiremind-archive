namespace :images do
  task :missing => :environment do
    Card.joins(:card_prints).where(card_prints: {with_image:true}).having("count(card_prints.id) = 0").each do |card|
      puts card.name
    end
  end

  task :verify, [:name] => :environment do |t,args|
    require 'colorize'
    if args[:name].blank?
      scope = CardPrint.all
    else
      scope = Edition.where(short: args[:name]).first!.card_prints
    end
    progress_bar = ProgressBar.new(scope.count)
    scope.find_each(batch_size: 50) do |cp|

      edition = cp.edition
      edition_key = edition.short
      url = "#{IMAGE_SERVER_URL}#{edition_key}/#{cp.get_relative_id}.jpg"
      res = FastImage.size(url)
      if res
        if res == [480, 680]
          unless cp.with_image && cp.card.primary_print
            cp.with_image = true
            cp.save!
            unless (card = cp.card).primary_print
              card.primary_print = cp
              card.save!   
            end
            puts "Enabling image on #{cp}".green
          end
        else
          puts "Wrong resolution #{cp} #{res} #{url}".yellow
        end
      else # not found
        if cp.with_image
          puts "Should have image but is missing #{cp} #{url}".red
          cp.with_image = false
          cp.save!
        else
          puts "Has no image #{cp} #{url}".yellow
        end
      end
      progress_bar.increment
    end
  end

  desc "Rename card scan files"
  task :rename, [:name] => :environment do |t, args|
    raise "No name given" if args[:name].blank?
    Edition.where(short: args[:name] ).each do |e|
      val = e.short
      scan_root = "/home/rails-dev/#{val}"
      e.card_prints.each do |c|
        new_card_path = "#{scan_root}/#{c.nr_in_set}.jpg"
        next if File.exists? new_card_path
        card_path = nil
        %w(full).each do |type|
          next if File.exists?(card_path="#{scan_root}/#{Card.encode_cardname(c.name)}.#{type}.jpg")
          next if File.exists?(card_path="#{scan_root}/#{c.multiverse_id}.jpg")
          (1..5).each do |i|
            break(2) if File.exists?(card_path="#{scan_root}/#{Card.encode_cardname(c.name)}#{i}.#{type}.jpg")
          end
        end

        if File.exists?(card_path)
          cf = File.new(card_path)
          Dir.mkdir(scan_root) if ! File.directory?(scan_root)
          raise "Already there #{new_card_path}" if File.exists? new_card_path
          FileUtils.mv(cf.path, new_card_path)
        else
          puts "No file found for #{c.name} id #{c.nr_in_set}: #{card_path}"
        end
      end
    end

  end

  desc "Fetch missing card images"
  task :fetch_missing , [:name, :force] => :environment do |t, args|
    require 'net/http'

    card_prints = Edition.where(short: args[:name]).first.card_prints.where.not(nr_in_set: nil)
    unless args[:force]
      card_prints = card_prints.where(with_image: false)
    end
    card_prints.find_each(batch_size: 50) do |card|
      edition = card.edition
      edition_key = edition.short
      url = URI.parse("#{IMAGE_SERVER_URL}#{edition_key}/#{card.get_relative_id}.jpg")
      #req = Net::HTTP::Get.new(url.path)
      #req.use_ssl = true
      #res = Net::HTTP.start(url.host, url.port) {|http|
        #http.request(req)
      #}
      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = true
      #http.verify_mode = OpenSSL::SSL::VERIFY_NONE # read into this
      res = http.get(url.request_uri)
      if res.code.to_i == 404
        unless card.get_relative_id.blank?
          if !File.exists?("#{Rails.root}/dl_scans/#{edition_key}/#{card.get_relative_id}.jpg")
            #`mkdir -p dl_scans/#{edition_key}/ && cd dl_scans/#{edition_key}/ && wget http://api.mtgdb.info/content/hi_res_card_images/#{card.multiverse_id}.jpg -O #{card.get_relative_id}.jpg`
            cmd = "wget https://img.scryfall.com/cards/large/en/#{edition_key.downcase}/#{card.get_relative_id}.jpg"
            puts cmd
            `mkdir -p dl_scans/#{edition_key}/ && cd dl_scans/#{edition_key}/ && #{cmd} -O #{card.get_relative_id}.jpg`
            if $?.exitstatus > 0
              `rm dl_scans/#{edition_key}/#{card.get_relative_id}.jpg`
              cmd = "wget https://img.scryfall.com/cards/large/en/#{edition_key.downcase}/#{card.get_relative_id}a.jpg"
              `mkdir -p dl_scans/#{edition_key}/ && cd dl_scans/#{edition_key}/ && #{cmd} -O #{card.get_relative_id}.jpg`
              if $?.exitstatus > 0
                `rm dl_scans/#{edition_key}/#{card.get_relative_id}.jpg`
              end
            end
          end
        else
          puts edition.name
          puts card.card.name
          puts url.path
        end
      elsif res.code.to_i == 200
        card.with_image = true
        card.save(validate: false)
      else
        puts "unknown code #{res.code.to_i} at #{url}"
      end
    end
    puts "rsync -av dl_scans/#{args[:name]}/ root@static.firemind.ch:/var/www/static/scans/#{args[:name]}"
  end

end
