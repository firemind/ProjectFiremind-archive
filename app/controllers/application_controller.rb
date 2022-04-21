class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :null_session, prepend: true
  before_action :set_raven_context
  before_action :configure_permitted_parameters, if: :devise_controller?
  rescue_from ActionController::UnknownFormat, with: :raise_not_supported

  def raise_not_supported
     render(text: 'Not Supported Format', status: :unsupported_media_type)
  end

  protected
  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name])
  end

  def restrict_access
    @user = authenticate_or_request_with_http_token do |token, options|
      if token.length > 0
        if @queue = DuelQueue.where(access_token: token).first
          @queue.user || User.sysuser
        else
          User.where(access_token: token).first
        end
      else
        false
      end
    end
  end

  private

  def set_raven_context
    Raven.user_context(id: session[:current_user_id]) # or anything else in session
    Raven.extra_context(params: params.to_unsafe_h, url: request.url)
  end

  def sanitize_string_fulltext_search(str)
    str.gsub /[^\p{L}\p{N}_]+/u, ' '
  end
end
