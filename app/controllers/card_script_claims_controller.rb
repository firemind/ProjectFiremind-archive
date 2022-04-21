class CardScriptClaimsController < ApplicationController


  def index
    @claims = User.find(params[:id]).card_script_claims
  end
end
