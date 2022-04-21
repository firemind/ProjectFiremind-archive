class SideboardScoring

  def initialize(inputs, outputs, matchups)
    @inputs = inputs
    @outputs = outputs
    @matchups = matchups
  end

  def score_sideboard_option(sideboard)
    @matchups.sum do|i, perc|
       perc * normalize_difference(@outputs[i] - sideboard.sum{|card, amount|
         [@inputs[i][card] ||0, amount].min
       })
    end
  end

  def normalize_difference(x)
    x < 0 ? x.to_f/10 : x
  end

end
