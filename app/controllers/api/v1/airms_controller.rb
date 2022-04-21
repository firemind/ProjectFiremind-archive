class Api::V1::AirmsController < ApplicationController
  before_action :restrict_access
  layout false

  def fetch
    @airm = @queue.ai_rating_match
    if @airm.finished?
      raise ActionController::RoutingError.new('Not Found')
    end
  end

end
