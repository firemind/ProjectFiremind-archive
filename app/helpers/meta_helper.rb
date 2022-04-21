module MetaHelper
  def format_win_percentage(s_archetype, o_archetype)
    if s_archetype == o_archetype
      return "50%"
    end
    games = s_archetype.game_count_against(o_archetype)
    return "?" if games == 0
    wins = s_archetype.win_count_against(o_archetype)
    res = ((wins.to_f / games.to_f) * 100.0).round
    lc = if res > 55
           "success"
    elsif res > 40
      ""
    else
      "alert"
    end
    "<span class='label #{lc}' title='Out of #{games} games'>#{res}%</span>".html_safe
  end
end
