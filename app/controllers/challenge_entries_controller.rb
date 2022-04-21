class ChallengeEntriesController < ApplicationController 
  before_action :authenticate_user!, only: [:create]

  def create
    @challenge_entry      = ChallengeEntry.new(challenge_entry_params)
    @challenge_entry.user = current_user


    respond_to do |format|
      if @challenge_entry.save
        @challenge_entry.create_duel
        format.html { redirect_to @challenge_entry.deck_challenge, notice: 'Challenge Entry was successfully created.' }
      else
        format.html { redirect_to @challenge_entry.deck_challenge, alert: "Can't create Challenge Entry: "+@challenge_entry.errors.full_messages.join(", ") }
      end
    end
  end
  
  private

  def challenge_entry_params
    params.require(:challenge_entry).permit(:deck_list_id, :deck_challenge_id)
  end
end
