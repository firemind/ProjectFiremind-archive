class AssignArchetypeWorker
  include Sidekiq::Worker

  def perform(deck_list_id)
    dl = DeckList.find deck_list_id

    client = TfArchetypeClient.new
    res = client.query([dl])[0]
    a, val = res[:predicted], res[:score]
    
    dl.archetype_score = val
    if dl.archetype_score < MIN_ARCHETYPE_SCORE || !dl.formats.include?(a.format)
      dl.archetype = if dl.formats.include?(a.format)
        a.format.no_archetype
      elsif f = ( (d = dl.decks.first) && dl.formats.include?(d.format) && d.format) || dl.formats.enabled.first
        f.no_archetype
      else
        vintage = Format.vintage
        dl.formats.include?(vintage) ? vintage.no_archetype : nil
      end
    else
      dl.archetype = a
    end
    dl.save!
  end

end
