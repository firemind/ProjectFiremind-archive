class GeneticSideboardWorker
  include Sidekiq::Worker

  def perform(deck_id, meta_id=nil)
    require 'sideboard_scoring'
    deck = Deck.find deck_id
    inputs  = {}
    outputs = {}
    matchups = []
    @sideboard_options = {}
    @irriducible = 0
    deck.sideboard_plans.each do |sp|
      matchups |= [sp.archetype.id]
      ins = {}
      total_cards_in = 0
      sp.sideboard_ins.each do |si|
        total_cards_in += si.amount
        ins[si.card.id] = si.amount
        @sideboard_options[si.card.id] ||= 0
        @sideboard_options[si.card.id] = si.amount if @sideboard_options[si.card.id] < si.amount
      end
      inputs[sp.archetype.id] = ins

      total_cards_out = sp.sideboard_outs.sum(:amount)
      outputs[sp.archetype.id] = total_cards_out

      @irriducible += [total_cards_out - total_cards_in, 0].max
    end

    if meta_id
      meta = Meta.find meta_id
      meta_percentages = meta.percentage_map.select{|k,v| matchups.include? k}
    else
      meta_percentages= Hash[matchups.map{|m| [m, 1.0 /matchups.size] }]
    end
    @scorer = SideboardScoring.new(inputs, outputs, meta_percentages)

    @sideboard_pool = []
    @sideboard_options.each {|key, val| val.times{ @sideboard_pool << key}}

    @sideboard_size = 15

    best_sideboard = nil
    best_score = -1000

    @population = Containers::PriorityQueue.new
    @population.instance_eval do
      def next_with_key
        [@heap.next, @heap.next_key]
      end
    end
    puts "Irriducible: #{ @irriducible.to_s}"
    score_goal = 0 #-1*@irriducible -5
    puts "Score goal: #{score_goal}"
    800.times do
      add_to_population(@sideboard_pool.sample(15))
    end
    current_best = -1000
    generation_stagnation_count = 0
    while(best_score < score_goal)
      elite = (1..300).map { @population.pop }
      @population.clear
      1000.times {
        child = breed_specimen(elite.sample(2))
        add_to_population(child)
      }
      elite.each do |specimen|
        add_to_population(specimen)
      end
      200.times do
        add_to_population(@sideboard_pool.sample(15))
      end
      candidate, best_score = @population.next_with_key
      if best_score > current_best
        @winner = candidate
        current_best = best_score
        puts "current best score #{best_score} #{@winner.sort.inspect}"
        generation_stagnation_count = 0
      else
        generation_stagnation_count += 1
        if generation_stagnation_count > 20
          save_winner(deck, @winner, best_score, meta_id)
          break
        end
      end
    end
  end

  def save_winner(deck, winner, score, meta_id)
    puts "winner score:#{score}"
    ss = SideboardSuggestion.new
    ss.deck = deck
    ss.deck_list = deck.deck_list
    ss.score = score*-1
    ss.meta_id = meta_id
    puts "best score #{score} #{winner.inspect}"
    ss.sideboard = winner.map do |card_id, amount|
      "#{amount} #{Card.find card_id}"
    end.join("\n")
    ss.algo = :genetic
    ss.save!
    puts ss.sideboard
  end

  def add_to_population(sb)
    if sb.is_a? Hash
      mapped = sb
    else
      mapped =  sb.each_with_object(Hash.new(0)) { |card,counts| counts[card] += 1 }
    end
    score = -1*@scorer.score_sideboard_option(mapped)
    @population.push(mapped, score)
  end

  def mutate(specimen)
    take = specimen.keys.sample
    give = (@sideboard_options.keys - [take]).sample
    if specimen[give] < @sideboard_options[give]
      if specimen[take] > 1 
        specimen[take] -= 1
      else
        specimen.delete take
      end
      specimen[give] ||= 0
      specimen[give] += 1
    end
  end

  def breed_specimen(parents)
    p1, p2 = parents  
    mutate(p1) if rand(30) == 0
    pool = []
    (p1.keys|p2.keys).each do |card|
      [p1[card]||0, p2[card]||0 ].max.times do
        pool << card
      end
    end
    pool.sample(15)
  end
end
