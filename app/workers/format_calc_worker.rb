class FormatCalcWorker
  include Sidekiq::Worker

  def perform(deck_list_id, capture_errors: nil, formats: nil)
    deck_list = DeckList.find(deck_list_id)
    process_dl(deck_list)
  end

  def process_dl(deck_list, capture_errors: nil, formats: nil, nolog: false)
    before_formats = deck_list.formats.pluck(:id)
    deck_entries = deck_list.deck_entries.to_a
    deck_count = deck_entries.collect(&:amount).inject(0, &:+)
    legalities_binary = deck_list.to_legalities_binary
    ((formats && Format.find(formats)) || Format.enabled).each do |format|
      illigal_cards_binary = ~format.legalities.to_i & legalities_binary
      legal = illigal_cards_binary == 0
      if !legal && capture_errors
        card_ids = Card.card_ids_at(illigal_cards_binary)
        Card.find(card_ids).each do |c|
          capture_errors << "#{format}: Card not legal #{c.name}"
        end
      end

      if legal
        restricted = format.restricted_cards.where(limit: 1).pluck(:card_id)
        if (resmatch = restricted & deck_entries.select{|r| r.amount > 1}.map(&:card_id)).size > 0
          capture_errors << "Card(s) restricted #{Card.find(resmatch).map(&:name)}" if capture_errors
          legal = false
        end
      end

      if legal
        deck_entries.select{|r| r.amount > format.max_copies}.each do |de|
          unless de.card.not_limited?
            legal = false 
            capture_errors << "More than max copies of #{de.card.name}" if capture_errors
          end
        end
      end

      # perform further checks and remove unwanted formats
      if legal
        if deck_count < format.min_deck_size
          legal = false
          capture_errors << "Deck is smaller than min size #{format.min_deck_size}" if capture_errors
        end
        if format.max_deck_size && deck_count > format.max_deck_size
          legal = false
          capture_errors << "Deck is larger than max size #{format.max_deck_size}" if capture_errors
        end
      end
      if legal
        deck_list.make_legal_in(format) unless deck_list.legal_in?(format)
      else
        deck_list.formats.destroy(format)
        deck_list.ratings.where(format_id: format.id).delete_all
      end
    end
    unless nolog
      after_formats = deck_list.formats.map(&:id)
      #raise "Less things legal #{deck_list.id} #{before_formats} #{after_formats}" if (before_formats-after_formats).size > 0
      FormatCalcLog.create(deck_list_id: deck_list.id, formats: deck_list.formats.map(&:id).join(","))
    end
  end

end
