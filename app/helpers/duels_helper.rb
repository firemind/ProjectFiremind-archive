module DuelsHelper
  def deck_list_image_url(deck_list)
    image_url(archetype_avatar_path(deck_list.archetype))
  end
  def add_card_tooltips(content)
    content = content.split("\r\n")
    content.collect do |line|
      m = /^(\d+)x? (.*)$/.match(line)
      if m
        number   = m[1]
        cardname = m[2]
        card = Card.where(name: cardname).first
        if (card)
          "#{number} #{card_link(card)}"
        else
          "#{number} #{cardname} (Not Found)"
        end
      else
        line
      end
    end
  end

  def format_state(state)
    label_class = case state
                  when 'finished' then 'success'
                  when 'failed' then 'alert'
                  when 'new' then 'secondary'
                  else ''
                  end
    "<span class='label #{label_class}'>#{state}</span>".html_safe
  end

  def class_for_duel_state(duel)
    duel.state.to_s
  end

  def class_for_game_score(wins, losses)
    if wins > losses
      'winning'
    elsif wins < losses
      'losing'
    else
      ''
    end
  end
end
