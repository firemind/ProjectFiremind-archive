class TournamentsController < ApplicationController

  def index
    @tournaments = Tournament.order("created_at desc")
  end

  def show
    @tournament = Tournament.find params[:id]
  end
end
