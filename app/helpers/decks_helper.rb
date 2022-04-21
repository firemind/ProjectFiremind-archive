module DecksHelper
  def format_game_result(result)
    "<span class='label #{result == 'win' ? 'success':'alert'}'>#{result}</span>".html_safe
  end

  def deck_avatar_tag(deck, grayscale= false)
    image_tag deck_avatar_path(deck), class: grayscale ? 'grayscale' : ''

  end

  def deck_avatar_path(deck)
    if thumb = deck.thumb_print
      thumb_print_url(thumb)
    else
      avatar_path(deck.avatar ? deck.avatar : 'avatar01.png')
    end
  end

  def deck_list_avatar_tag(deck_list, grayscale: false)
    archetype = deck_list.archetype
    image_tag archetype_avatar_path(archetype), class: grayscale ? 'grayscale' : ''
  end


  def avatar_path(img)
    "avatars/#{img}"
  end

  def alert_class_for_rating(rating)
    rating = rating.to_i
    case
    when rating > 100
      'success'
    when rating > 50
      ''
    when rating > 0
      'secondary'
    when rating < 0
      'alert'
    end
  end

  def cell_class_for_rating(rating)
    rating = rating.to_i
    case
    when rating > 100
      'success'
    when rating > 20
      ''
    when rating < -100
      'alert'
    else
      'secondary'
    end
  end

  def mulligan_avg_label(val, other)
    if val
      val_formatted = "#{(val*100).round}%"
      if other
        if (val - other).abs > 0.50
          %Q(<span class="label alert">#{val_formatted}</span>).html_safe
        elsif (val - other).abs > 0
          %Q(<span class="label secondary">#{val_formatted}</span>).html_safe
        else
          %Q(<span class="label success">#{val_formatted}</span>).html_safe
        end
      else
        val_formatted
      end
    end
  end

end
