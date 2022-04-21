class PriceProvider::Supernova
  SKIP_EDITIONS = %w(BOO PRM VAN TD2 PR TD0)

  def self.map(cardname, edition_short)
    return if SKIP_EDITIONS.include? edition_short
    cardname = cardname.force_encoding("ISO-8859-1").encode("utf-8").gsub('/', ' // ')
    return nil if edition_short == 'ORI' && ['Nightmare', 'Terra Stomper', 'Mahamoti Djinn', 'Into the Void', 'Aegis Angel', 'Shivan Dragon'].include?(cardname)
    c = Card.find_by_name(cardname)
    unless c
      puts "Card not found #{cardname}"
      return nil
    end
    cp = c.card_prints.joins(:edition).where(editions: {short: short_by_supernova(edition_short)}).first
    puts "CardPrint not found #{cardname} in #{edition_short}" unless cp
    return cp
  end

  def self.process_line(line)
    match = /^([^\[\]]+) \[([A-Z0-9]+)\]\s+([0-9]+[\.0-9]*)?\s+([0-9]+[\.0-9]*)?/.match(line)
    if match
      cp = PriceProvider::Supernova.map(match[1],match[2])
      unless cp
        return
      end
      if match[3]
        # TODO figure out what to do with buying prices
      end
      if match[4]
        new_m = match[4]
        cp.update_price!(new_m, source: :supernova)
      end
    end
  end

  def self.short_by_supernova(short)
    SUPERNOVA_EDITION_MAPPING[short] || short
  end

end

SUPERNOVA_EDITION_MAPPING = {
  #'PC1' => 'PCH',
  'CSP' => 'CS',
  'SCG' => 'SC',
  '8ED' => '8E',
  '9ED' => '9E',
  'TOR' => 'TO',
  'MRD' => 'MR',
  'JUD' => 'JU',
  'ONS' => 'ON',
  'ST'  => 'SH',
  'UZ'  => 'US',
  'MED'  => 'ME',
  'LGN' => 'LE',
  'GPT' => 'GP',
  'DST' => 'DS',
  #'ALL' => 'AL',
  #'ICE' => 'IA'
}
