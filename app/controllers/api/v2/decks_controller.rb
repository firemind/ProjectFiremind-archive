class Api::V2::DecksController < Api::V2::BaseController

  def my
    render json: current_user.decks.first(5)
  end
end
