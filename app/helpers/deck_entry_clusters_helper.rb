module DeckEntryClustersHelper
  def hypergeo(indeck, decksize, drawn, n)
    #c(indeck, n) * c(decksize - indeck, drawn - n) / c(decksize, drawn)

    Distribution::Hypergeometric.cdf( n-1, indeck, drawn, decksize)
  end

  def c(x,y)
    fact(x, y) /  fact(1,y)
  end

  def fact(s, n)
    ((s..n).inject(:*) || 1).to_f
  end

  def hand_entry_probability(deck, hand_size)
    decksize = deck.card_count
    hand_combos = []
    num_fixed_cards = deck.playable_hand_entries.sum(:min_amount)
    variance = hand_size - num_fixed_cards
    varying_entries = []
    fixed_entries = []
    deck.playable_hand_entries.each do |phe|
      v = phe.max_amount -  phe.min_amount
      v = variance if v > variance
      phe.min_amount.times do
        fixed_entries << phe
      end
      v.times do
        varying_entries << phe
      end
    end
    variance.times do
      varying_entries << nil
    end
    (1.0 - varying_entries.combination(variance).to_a.collect {|e| e.sort{|a,b| a && b ? a <=> b : a ? -1 : 1 }}.uniq.inject(1.0) do |sum, combo|
      prob = draw_probability_of(combo + fixed_entries, decksize, hand_size)

      sum * ((1 - prob) ** (hand_size * (combo + fixed_entries).uniq.size))
    end) * 100
  end

  def draw_probability_of(cards, decksize, draws)
    cards.inject(1.0) {|prob, entry|
      #prob * (entry.deck_entry_cluster.deck_entries.sum(:amount).to_f / decksize) * draws
      if entry
        indeck = entry.deck_entry_cluster.deck_entries.sum(:amount)
        if indeck > 0
          #hg =  1.0 - hypergeo( indeck, decksize, draws, 2).to_f
          #prob * hg
          prob * (indeck.to_f / decksize)
        else
          prob
        end
      else
        prob
      end
    }
  end
end
