class PriceProvider::Mlbot
  SKIP_EDITIONS = %w(BOO PRM VAN)

  def self.map(cardname, edition_short)
    begin
      cardname = URI.unescape(cardname).force_encoding("ISO-8859-1").encode("utf-8").gsub('+', " ").gsub('\\', '').gsub('/', ' // ').gsub("Elbrus", "Elbrus,")
    rescue
      raise "exception for "+cardname
    end
    c = Card.find_by_name(cardname)
    unless c
      puts "Card not found #{cardname}" unless cardname == "*therspouts"
      return nil
    end
    cp = c.card_prints.joins(:edition).where(editions: {short: short_by_mlbot(edition_short)}).first
    puts "CardPrint not found #{cardname} in #{edition_short}" unless cp
    return cp
  end

  def self.process_cards(cards)
    cards.each do |card_data|
      next if SKIP_EDITIONS.include? card_data['set_name']
      next if SKIP_EDITIONS.include? card_data['set_name']

      cp = PriceProvider::Mlbot.map(card_data['card_name'], card_data['set_name'])
      unless cp
        next
      end
      cp.mlbot_inventory =  card_data["sell_quantity"]
      cp.update_price!(card_data["sell_price"], type: 'mlbot_sell_price', source: :mlbot_api)
    end
  end

  def self.mlbot_short(short)
    MLBOT_EDITION_MAPPING.key(short) || short
  end

  def self.short_by_mlbot(short)
    MLBOT_EDITION_MAPPING[short] || short
  end

end

MLBOT_EDITION_MAPPING = {
  'PC1' => 'PCH',
  'CSP' => 'CS',
  'SCG' => 'SC',
  '8ED' => '8E',
  '9ED' => '9E',
  'TOR' => 'TO',
  'MRD' => 'MR',
  'JUD' => 'JU',
  'ONS' => 'ON',
  'ST'  => 'SH',
  'LGN' => 'LE',
  'GPT' => 'GP',
  'DST' => 'DS',
  'ALL' => 'AL',
  'ICE' => 'IA'
}
