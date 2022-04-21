class Api::V2::BaseController <  ActionController::Base
  include DeviseTokenAuth::Concerns::SetUserByToken
  #  protect_from_forgery :null_session
  before_action :authenticate_user!
  before_action :set_raven_context

  private

  def set_raven_context
    Raven.user_context(id: session[:current_user_id]) # or anything else in session
    Raven.extra_context(params: params.to_unsafe_h, url: request.url)
  end
end
