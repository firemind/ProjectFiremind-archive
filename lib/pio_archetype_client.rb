class PioArchetypeClient
  cattr_accessor :url
  attr_accessor :client

  def initialize
    self.client =  PredictionIO::EngineClient.new(url)
  end

  def send_query(*args)
    client.send_query(*args)
  end

  def request_decklist(deck_list, format_id)
    client.send_query(
      q: deck_list.deck_entries.where.not(group_type: 'lands').map{|r| [r.card_id, r.amount] }.compact,
      format_id: format_id
    )
  end
end
