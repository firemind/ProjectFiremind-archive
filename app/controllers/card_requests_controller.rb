class CardRequestsController < ApplicationController
  before_action :set_card_request, only: [:show, :vote]
  before_action :authenticate_user!, except: [:show, :create]

  ## GET /card_requests
  ## GET /card_requests.json
  #def index
    #@card_requests = CardRequest.all
  #end

  # GET /card_requests/1
  # GET /card_requests/1.json
  def show
  end


  # POST /card_requests
  # POST /card_requests.json
  def create

    @card_request = CardRequest.new(card_request_params)
    card = Card.where(enabled: false).where(id: params[:card_id] || card_request_params[:card_id]).first || @card_request.card
    if card
      if existing_request = CardRequest.where(card_id: card.id).first
        @card_request = existing_request
      else
        @card_request.card = card
        @card_request.state_comment = CardRequest::InitialComment
        @card_request.user= current_user
      end
    end

    respond_to do |format|
      if card
        if @card_request.save
          @card_request.vote_by :voter => current_user if current_user
          format.html { redirect_to @card_request, notice: "Your request to add #{@card_request} has been noted." }
          format.json { render 'show', status: :created, location: @card_request }
        else
          format.html { render 'new' }
          format.json { render json: @card_request.errors, status: :unprocessable_entity }
        end
      else
        format.html do
          redirect_to :root, flash: { error: "No such card." }
        end
      end
    end
  end

  def vote
    @card_request.vote_by :voter => current_user
    redirect_to @card_request, notice: "Thank you for voting"
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_card_request
      @card_request = CardRequest.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def card_request_params
      params[:card_request] = {card_id: params[:card_id]} if params[:card_id]
      params.require(:card_request).permit(:card_id, :card_name)
    end
end
