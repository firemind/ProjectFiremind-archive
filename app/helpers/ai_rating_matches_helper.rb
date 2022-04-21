module AiRatingMatchesHelper
  def format_state(state)
    label_class = case state
                  when 'finished' then 'success'
                  when 'failed' then 'alert'
                  when 'new' then 'secondary'
                  else ''
                  end
    "<span class='label #{label_class}'>#{state}</span>".html_safe
  end

  def rate_in_percent(wins, total)
    return 0 if total == 0
    percentage = wins.to_f / total.to_f
    return (percentage * 100).round
  end

  def duel_stats_for_ai(duel, ai)
    dq = duel.duel_queue
    if dq.ai1 == ai
      stat =  <<-TEXT
      #{link_to "#{duel.deck_list1} (#{duel.wins_deck1.to_i})", duel.deck_list1}
      #{dq.ai1}
      #{dq.ai1_strength}
      TEXT
    else
      stat = <<-TEXT
      #{link_to "#{duel.deck_list2} (#{duel.wins_deck2.to_i})", duel.deck_list2}
      #{dq.ai2}
      #{dq.ai2_strength}
      TEXT
    end
    stat.html_safe
  end

  def airm_chart_data(ainame)
    #identifiers = AiRatingMatch.select("distinct(concat_ws(' ', ai1_name,ai1_identifier))")
    identifiers = AiRatingMatch.where(ai1_name: ainame).select("distinct(ai1_identifier)").map &:ai1_identifier
    ops = AiRatingMatch.where(ai1_name: ainame).select("distinct(concat_ws(' ', ai2_name,ai2_identifier)) as t").map &:t
    identifiers.map{|idf|
      {
        name: idf,
        data: Hash[ops.map{|op|
        s = op.split(' ')
        [op, win_rate(ainame, idf, s[0], s[1..-1] )]
      }]
      }
    }
    #@top_decks.map{|deck| {name: deck.to_s, data: Hash[(0..7).map{|n| n.days.ago}.reverse.map{|day| [day.strftime("%Y-%m-%d"), (r = deck.rating_in(@format)) && (Date.current == day.to_date ? r : r.version_at(day)).to_s.to_i || 0]}]}}
  end

  def win_rate(ai1, ai1_idf, ai2, ai2_idf)
    wins = AiRatingMatch.by_ai_vs_ai(ai1, ai1_idf, ai2, ai2_idf).map{|r| r.wins}.sum +
      AiRatingMatch.by_ai_vs_ai(ai2, ai2_idf, ai1, ai1_idf).map{|r| r.losses}.sum
    total = AiRatingMatch.by_ai_idf(ai1, ai1_idf).map{|r| r.duels.map(&:games_to_play).sum}.sum
    total > 0 && wins > 0 ? (wins.to_f * 100 / total.to_f).round : nil
  end

  def to_dot_time(s)
    h = s / 3600
    s -= h * 3600

    m = s / 60
    s -= m * 60

    [h, m, s].join(":")
  end

end
