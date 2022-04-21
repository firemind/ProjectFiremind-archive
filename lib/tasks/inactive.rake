namespace :donotusebeforerefactor do
  task :read_mtgolibrary_prices => :environment do

    File.open("CardsMTGO3.txt", "r:UTF-8") do |infile|
      while (line = infile.gets)
        # Example Line
        # 01 000 01 000 001 5DN C Abuna's Chant# 0.019 0.029 0.005 0.008
        ar = line.split("#")
        card_name_raw = ar[0].split(" ")[7..-1].join(' ')
        card_name = card_name_raw.gsub(/\//, ' // ')
        edition_name = ar[0].split(" ")[5]
        card = Card.where(name: card_name).joins(:edition).where(editions: {short: Card.mlbot_mapped_edition(edition_name)}).first
        if card
          card = Card.find card.id
          prices = ar[1].split(" ")
          card.mtgo_price_avg = prices[0]
          card.mtgo_price_high = prices[1]
          card.mtgo_price_low = prices[2]
          card.mtgo_price_med = prices[3]
          card.mtgo_id = ar[0].split(" ")[4]
          card.mlbot_name = card_name_raw
          #card.mtgo_name =
          card.save
        else
          edition = Edition.where({short: Card.mlbot_mapped_edition(edition_name)}).first
          unless edition
            puts "No such edition #{edition_name}"
          else
            puts "No such card in edition #{edition.short} : #{card_name}"
          end
        end
      end
    end
  end

  task :write_personal_prices => :environment do
    mtgo_directory = "/tmp/"
    mtgo_directory = "/media/i7win7_c/Program Files (x86)/MTGOLibrary/MTGO Library Bot" if Rails.env.production?
    filepath = "#{mtgo_directory}/PersonalPricesFiremind.txt"
    File.open(filepath, 'w') { |file|
      file.write("SETNAME;CARDNAME;SELLING PRICE;FOIL SELLING PRICE;BUYING PRICE;FOIL BUYING PRICE;QUANTITY REGULAR;QUANTITY FOIL\n")
      Card.where("mtgo_buying_override is not null or mtgo_selling_override is not null or mtgo_buying_quantity is not null").each do |card|
        setname =  card.mlbot_edition
        cardname = card.mlbot_name || card.name
        selling = card.mtgo_selling_override
        foil_selling = ""
        buying = card.mtgo_buying_override
        foil_buying = ""
        quantity = card.mtgo_buying_quantity || 1
        foil_quantity = 0
        file.write("#{setname};#{cardname};#{selling};#{foil_selling};#{buying};#{foil_buying};#{quantity};#{foil_quantity}\n")
      end
    }
  end
end

