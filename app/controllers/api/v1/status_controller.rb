class Api::V1::StatusController < ApplicationController

  respond_to :json

  def client_info
    render json: {
      current_magarena_version: CURRENT_MAGARENA_VERSION,
      displayText: "Currently running magaren version "+CURRENT_MAGARENA_VERSION
    }
  end

end
