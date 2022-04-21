class WorkspaceController < ApplicationController
  before_action :authenticate_user!

  def index
    @claims = current_user.card_script_claims.includes(:card)
  end

  def add
    c = Card.find(params[:id])
    claim =  CardScriptClaim.new
    claim.card = c
    claim.user = current_user
    unless claim.save
      flash[:error] = "Can't add card to workspace"
    end
    redirect_to workspace_index_path
  end

  def destroy
    current_user.card_script_claims.where(id: params[:id]).first.destroy
    redirect_to workspace_index_path
  end

end
