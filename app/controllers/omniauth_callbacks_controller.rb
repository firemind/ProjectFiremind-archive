class OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def all
    auth = request.env["omniauth.auth"]
    if auth.info.email
      user = User.from_omniauth(auth)
      if user.persisted?
        flash[:notice] = "Signed in!"
        sign_in_and_redirect user, :event => :authentication
      else
        session["devise.user_attributes"] = user.attributes
        redirect_to new_user_registration_url
      end
    else
      flash[:error] = "Authentication did not return an e-mail address. User can't be created"
      redirect_to new_user_registration_url
    end
  end
  alias_method :twitter, :all
  alias_method :google_oauth2, :all
  alias_method :facebook, :all
  alias_method :github, :all
end
