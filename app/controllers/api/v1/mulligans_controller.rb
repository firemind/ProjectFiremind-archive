class Api::V1::MulligansController < ApplicationController
  respond_to :json
  before_action :restrict_access, only: [:decks, :hands_by_deck]

  include CardHelper

  def hands
    limit  = [200, (params[:limit] || 10).to_i].min
    hands = DealtHand.where(deck_list_id: Deck.where(public: true).pluck(:deck_list_id))

    if count_without_decision(hands) < 110
      d = Deck.where(public: true).order("rand()").first.deck_list
      d.create_dealt_hand(repeat: 50, hand_sizes: [7])
      d.create_dealt_hand(repeat: 20, hand_sizes: [6])
      d.create_dealt_hand(repeat: 10, hand_sizes: [5])
    end

    render_hands_for(hands.by_least_decisions.limit(limit))
  end

  def established_hands
    limit  = [200, (params[:limit] || 10).to_i].min
    hands = DealtHand.where(deck_list_id: Deck.where(public: true).pluck(:deck_list_id))

    render_hands_for(hands.decisions_at_least(3).limit(limit))
  end

  def hands_by_deck
    limit  = [200, (params[:limit] || 10).to_i].min

    if @user && @user.is_a?(User)
      d = Deck.visible_to(@user).where(deck_list_id: params[:deck_list_id]).first!
    else
      d = Deck.where(public: true).where(deck_list_id: params[:deck_list_id]).first!
    end
    d = d.deck_list
    hands = DealtHand.where(deck_list_id: d.id)
    if count_without_decision(hands) < 30
      d.create_dealt_hand(repeat: 50, hand_sizes: [7])
      d.create_dealt_hand(repeat: 20, hand_sizes: [6])
      d.create_dealt_hand(repeat: 10, hand_sizes: [5])
    end

    render_hands_for(hands.by_least_decisions.limit(limit))
  end

  def decks
    render json: {
      decks: @user.decks.map{|r|
        {
          id: r.id,
          name: r.title,
          archetype: r.deck_list.archetype.to_s,
          format: r.format.to_s,
          deck_list_id: r.deck_list_id
        }
      }
    }
  end

  def keep
    md = mark_mulligan_decision(false)
    render json: {id: md.id}
  end

  def mulligan
    md = mark_mulligan_decision(true)
    @new_hand = DealtHand.by_card_count(@dealt_hand.dealt_cards.size-1).
      where(deck_list_id: @dealt_hand.deck_list_id).
      order("RAND()").
      first
    if @new_hand
      render json: {id: md.id, next: @new_hand.id, draw: params[:draw]}
    else
      render json: {id: md.id}
    end
  end


  private

  def count_without_decision(scope)
    @hands = scope.dup.
      joins("LEFT JOIN mulligan_decisions ON dealt_hands.id = mulligan_decisions.dealt_hand_id").
      having("count(mulligan_decisions.id) = 0").group("dealt_hands.id").size.keys.size
  end

  def render_hands_for(scope)

    @hands = scope.includes(dealt_cards: :card)

    render json: {
      hands: @hands.map{|hand|{
        id: hand.id,
        deck_list_id: hand.deck_list_id,
        mulligan_count: hand.mulligan_count,
        keep_count: hand.keep_count,
        cards: hand.dealt_cards.map {|r|{
          id: r.id,
          card: {
            id: r.card.id,
            name: r.card.name,
            image: card_image_url(r.card.primary_print)
          }
        }}
      }}
    }
  end

  def mark_mulligan_decision(mulligan)
    if request.headers["Authorization"]
      restrict_access
    end
    @dealt_hand = DealtHand.find(params[:id])

    res = MulliganDecision.where(
      dealt_hand_id: @dealt_hand.id,
      draw: params[:draw]
    ).select("sum(mulligan) as mulls, count(id) as count").first


    md = MulliganDecision.create(
      dealt_hand_id: @dealt_hand.id,
      mulligan: mulligan,
      draw: params[:draw],
      source_ip: request.remote_ip,
      user_id: @user.is_a?(User) && @user.id
    )

    flash[:notice] = "Thanks for playing."
    if res && res.count > 0
      ratio = res.mulls.to_f / res.count.to_f
      agrees = mulligan ? ratio : 1-ratio
      flash[:notice] += " #{(agrees * 100).round}% agree with you"
    end
    md
  end

end
