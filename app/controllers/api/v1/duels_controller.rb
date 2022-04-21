class Api::V1::DuelsController < ApplicationController
  before_action :restrict_access
  respond_to :json

  def create
    dp =  duel_params
    format_name = dp.delete(:format_name)
    @duel = Duel.new(dp)
    @duel.user = @user
    @duel.state = 'waiting'
    @duel.duel_queue = @queue

    if !@duel.freeform && format_name && Format::PRIMARY_FORMATS.include?(format_name.to_sym)
      @duel.format = Format.where(enabled: true, format_type: format_name.to_sym).first
    end

    if @duel.save
      DuelInformWorker.perform_async @duel.id
      render json: { duel: {id: @duel.id}}, status: :created, location: @duel 
    else
      render json: @duel.errors, status: :unprocessable_entity 
    end
  end

  private
    def duel_params
      params.require(:duel).permit(:games_to_play, :deck_list1_id, :deck_list2_id, :public, :format_name, :freeform)
    end

end
