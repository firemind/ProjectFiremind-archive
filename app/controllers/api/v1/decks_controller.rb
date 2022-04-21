class Api::V1::DecksController < ApplicationController
  before_action :restrict_access
  respond_to :json

  def create
    format = (f = params[:format_name]) ? Format.where(name: f).first : Format.vintage
    dp =  deck_params
    @deck = Deck.new(dp)
    @deck.author = @user
    @deck.format = format

    if @deck.save
      render json: { deck: {
        id: @deck.id,
        deck_list_id: @deck.deck_list.id
      }}, status: :created, location: @deck 
    else
      render json: @deck.errors, status: :unprocessable_entity 
    end
  end

  private
    def deck_params
      params.require(:deck).permit(:title, :description, :decklist, :avatar, :format_id)
    end

end
