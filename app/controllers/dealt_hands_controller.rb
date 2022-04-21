class DealtHandsController < ApplicationController
  def export
    @dealt_hands = DealtHand.where(id: MulliganDecision.select("distinct(dealt_hand_id)").includes(:mulligan_decisions).pluck("dealt_hand_id"))
    respond_to do |format|
      #format.html { redirect_to @dealt_hands, notice: 'Duel was successfully created.' }
      format.json { render json: {mulligan_results: @dealt_hands} }
      format.csv { send_data @dealt_hands.to_csv }
    end
  end

  def show
    @dealt_hand = DealtHand.includes(dealt_cards: :card).find(params[:id])
    @draw = params[:draw].nil? ? [true, false].sample : params[:draw] == 'true'
    @current_time = Time.now
  end

  def sample
    redirect_to DealtHand.by_card_count(7).order("RAND()").first
  end

  def keep
    mark_mulligan_decision(false)
    redirect_to sample_dealt_hands_path
  end

  def mulligan
    mark_mulligan_decision(true)
    @new_hand = DealtHand.by_card_count(@dealt_hand.dealt_cards.size-1).
      where(deck_list_id: @dealt_hand.deck_list_id).
      order("RAND()").
      first
    if @new_hand
      redirect_to dealt_hand_path(@new_hand, draw: params[:draw])
    else
      redirect_to sample_dealt_hands_path
    end
  end

  def tooltip
    @dealt_hand = DealtHand.find(params[:id])
    render layout: false
  end

  private

  def mark_mulligan_decision(mulligan)
    @dealt_hand = DealtHand.find(params[:id])

    res = MulliganDecision.where(
      dealt_hand_id: @dealt_hand.id,
      draw: params[:draw]
    ).select("sum(mulligan) as mulls, count(id) as count").first

    MulliganDecision.create(
      dealt_hand_id: @dealt_hand.id,
      mulligan: mulligan,
      draw: params[:draw],
      time_taken: Time.now - Time.parse(params[:starting_time]),
      source_ip: request.remote_ip,
      user_id: @current_user && @current_user.id
    )

    flash[:notice] = "Thanks for playing."
    if res && res.count > 0
      ratio = res.mulls.to_f / res.count.to_f
      agrees = mulligan ? ratio : 1-ratio
      flash[:notice] += " #{(agrees * 100).round}% agree with you"
    end
  end

end
