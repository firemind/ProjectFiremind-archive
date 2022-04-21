module CardHelper
  def card_link(card, text=nil)
    text ||=card.name
    link_to text, card,
      class: 'card-with-tooltip',
      data: {url: tooltip_card_path(card)}
      #data: {ot: {ajax: tooltip_card_path(card), style: 'dark', shadow: false, showOn: 'creation', hideDelay: 0, showEffectDuration: 0, hideEffectDuration: 0}}
  end

  def card_image_url(card_print)
    edition = card_print.edition
    edition_key = edition.short
    "#{IMAGE_SERVER_URL}/#{edition_key}/#{card_print.get_relative_id}.jpg"
  end
end
