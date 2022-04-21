module DeckListsHelper

  def calculate_matchup_percentages(deck_list)
    res = {}
    win_counts  = deck_list.won_games.joins(losing_deck_list: :archetype).group(:archetype_id).select("count(games.id) as win_count, archetypes.id as archetype_id").map {|r| [r.archetype_id, r.win_count] }.to_h
    loss_counts = deck_list.lost_games.joins(winning_deck_list: :archetype).group(:archetype_id).select("count(games.id) as loss_count, archetypes.id as archetype_id").map {|r| [r.archetype_id, r.loss_count] }.to_h
    Archetype.where(id: win_counts.keys|loss_counts.keys).each do |at|
      wins   = win_counts[at.id] || 0
      losses = loss_counts[at.id] || 0
      if (total = wins+losses) > 0
        res[at] ={
          win_percentage: wins.to_f / total * 100,
          wins: wins,
          losses: losses
        }
      end
    end
    res.sort_by{|k,v| -v[:win_percentage]}
  end

  def binomial(n,x,p)
    ( fact(n,x) / ( fact(n - x))) * p**x * (1 - p)**(n - x)
  end

  def cumulative_prob(n,x,p)
    (x..n).inject(0){|s,y| s+binomial(n,y,p)}
  end

  def fact(n, stop=1)
    (stop..n).inject(:*) || 1
  end

  def ztest(m,v,n)
    se = v/(n**0.5)
    z = ()
  end

  def clt_confidence(n,w)
    [
     w/n - 1.96 * (w/n*(1-w/n)/n)**0.5,
     w/n + 1.96 * (w/n*(1-w/n)/n)**0.5,
    ]
  end


end
