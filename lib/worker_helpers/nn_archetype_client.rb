class NnArchetypeClient

  def self.send_query(dl)
    client = TCPSocket.new Rails.configuration.x.archetype_server, ArchetypeNnPort
    cids = dl.deck_entries.pluck(:card_id)
    deck = dl.decks.first
    format = (deck && deck.format.enabled && deck.format_id) || nil
    client.puts({cids: cids, format: format}.to_json)
    line = client.gets
    data = JSON.parse line.chomp
    if Rails.env.test?
      unless Archetype.where(id: data[0]).first
        Archetype.create(id: data[0], 
                         name: "Test Archetype #{data[0]}", 
                         format_id: 37,
                         avatar_num: 23)
      end
    end
    return [Archetype.find(data[0]),data[1]]
  end

end
