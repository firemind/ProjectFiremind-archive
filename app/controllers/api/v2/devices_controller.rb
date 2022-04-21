class Api::V2::DevicesController < Api::V2::BaseController

  def register
    current_user.device = params[:id]
    current_user.save!
    #app = Rpush::Gcm::App.new
    #app.name = "android_app"
    #app.auth_key = 'AIzaSyAjG-FmkOmjvH5M6ViMNX8IQIdphhaapz8'
    #app.connections = 1
    #app.save!

    render json: 'success'
  end
end
