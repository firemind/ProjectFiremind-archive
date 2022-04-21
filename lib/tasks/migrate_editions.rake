task :migrate_editions => :environment do 
  EDITION_MAPPING = {
    'AL' => 'ALL',
    'A' => 'LEA',
    'B' => 'LEB',
    'U' => 'LEB',
    '4E' => '4ED',
    'TE' => 'TMP',
    'R' => '3ED',
    'AN' => 'ARN',
    'VI' => 'VIS',
    '9E' => '9ED',
    '8E' => '8ED',
    '7E' => '7ED',
    '6E' => '6ED',
    '5E' => '5ED',
    'DK' => 'DRK',
    'MI' => 'MIR',
    'AQ' => 'ATQ',
    'LG' => 'LEG',
    'CH' => 'CHR',
    'HL' => 'HML',
    'IA' => 'ICE',
    'US' => 'USG',
    'UL' => 'ULG',
    'SH' => 'STH',
    'EX' => 'EXO',
    'WL' => 'WTH',
    'ON' => 'ONS',
    'TO' => 'TOR',
    'PS' => 'PLS',
    'UD' => 'UDS',
    'MR' => 'MRD',
    'JU' => 'JUD',
    'IN' => 'INV',
    'DS' => 'DST',
    'ST' => 'S99',
    'AP' => 'APC',
    'MM' => 'MMQ',
    'NE' => 'NMS',
    'LE' => 'LGN',
    'PY' => 'PCY',
    'SC' => 'SCG',
    'OD' => 'ODY',
    'FD' => '5DN',
    'GP' => 'GPT',
    'CS' => 'CSP',
    #'CFX' => 'CON',
    'FE' => 'FEM',
    'CRS' => 'CM1',
    'S2' => 'S00',
    'PT' => 'POR',
    'P2' => 'PO2',
    'P3' => 'PTK',
    'PCH' => 'HOP',
    'ME' => 'MED',
    'DVD' => 'DD3_DVD',
    'GVL' => 'DD3_GVL',
    'EVG' => 'DD3_EVG',
    'JVC' => 'DD3_JVC',
  }
  base_path = "/mnt/fileshare/thumbs/"
  EDITION_MAPPING.each do |k,v|
    edition = Edition.where(short: v).first
    next unless edition
    old_path = File.join(base_path, k)
    new_path = File.join(base_path, v)
    if File.exists?(old_path) 
      if File.exists?(new_path)
        raise "New path already exists #{old_path} =>  #{new_path}"
      else
        puts "sudo mv #{old_path} #{new_path}"
      end
    end


  end
end
