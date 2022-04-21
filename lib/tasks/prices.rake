namespace :prices do
  desc "read supernovabot prices"
  task :read_supernova => :environment do
    require 'open-uri'
    open("http://www.supernovabots.com/prices_0.txt") do |f|
      f.each_line do |line|
        # example line:
        # Sorin, Solemn Visitor [KTK]               13.2      13.85     mr[2] p3[2] s1[2]
        PriceProvider::Supernova.process_line(line)
      end
    end
  end

  desc "mlbot inventory update"
  task :read_mlbot_inventory => :environment do
    api = MlbotApi.new
    Edition.where(mtgo: true).each do |edition|
      cards = api.inventory(PriceProvider::Mlbot.mlbot_short(edition.short), nil)
      next unless cards
      PriceProvider::Mlbot.process_cards(cards)
    end
  end
end

