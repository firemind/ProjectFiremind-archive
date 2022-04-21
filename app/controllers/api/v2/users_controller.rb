class Api::V2::UsersController < Api::V2::BaseController

  def profile
    render json: {
      email: current_user.email,
      name: current_user.name,
      duel_count: current_user.duels.count
    }
  end
end
