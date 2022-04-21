module ApplicationHelper
  def populate_manasymbols(line)
    return "" if !line
    {
      G: 'green', U: 'blue', B: 'black', R: 'red', W: 'white', X: 'x',
      GW: 'green-white', WB: 'white-black', RW: 'red-white'
    }.each do |k,v|
      line.gsub!("{#{k}}", "<span class='mana-#{v}'>&nbsp</span>")
    end
    (0..20).each do |c|
      line.gsub!("{#{c}}", "<span class='colorless-#{c}'>&nbsp</span>")
    end
    line.html_safe
  end

  def add_search_links_to_ability(ability)
    output = []
    ability.split(/£|\n/).each do |line|
      unless line.blank?
        if line.length < 20
          output << link_to(line, search_cards_path(query: line, only_enabled: true))
        else
          output << line
        end
      end
    end
    
    output.join('<br>').html_safe
  end

  def color_tag(colors)
    tag.div class: "colorbox" do
      contents = []
      contents << tag.div(class: "mana-white") if colors =~ /W/
      contents << tag.div(class: "mana-blue" ) if colors =~ /U/
      contents << tag.div(class: "mana-black") if colors =~ /B/
      contents << tag.div(class: "mana-red"  ) if colors =~ /R/
      contents << tag.div(class: "mana-green") if colors =~ /G/
      contents.join("").html_safe
    end 
  end

  def deck_select_options(decks, selected)
    options_for_select(decks.map { |deck|
      [
          deck.deck_list_id,
          deck.deck_list_id,
          {
              data: {
                  'img-src' => asset_path(deck_avatar_path(deck)),
                  'img-label' => link_to(deck.title.truncate(18),
                                         "#",
                                         class: 'card-with-tooltip',
                                         data: {url: tooltip_deck_list_path(deck.deck_list)})
              }
          }
      ]
    }, selected: selected)
  end

  def user_deck_for(deck_list)
    current_user && deck = current_user.decks.where(deck_list_id: deck_list.id).first
  end

  def thumb_print_url(thumb)
    "#{THUMB_SERVER_URL}#{thumb.edition.short}/#{thumb.nr_in_set}.jpg"
  end

  def archetype_avatar_path(archetype)
    thumb = archetype&.thumb_print
    if thumb
      thumb_print_url(thumb)
    else
      "avatars/avatar01.png"
    end
  end

  def admin_user?
    current_user&.id == 49
  end

end
