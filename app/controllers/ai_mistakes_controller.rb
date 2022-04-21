class AiMistakesController < ApplicationController
  #def new
    #game = Game.find(params[:game_id])
    #@ai_mistake = AiMistake.new(game: game, log_line_number: params[:line_number], decision: game.get_decision_on_line(params[:line_number].to_i))
  #end

  #def create
    #@ai_mistake = AiMistake.new(ai_mistake_params)
    #@ai_mistake.user = current_user

    #respond_to do |format|
      #if @ai_mistake.save
        #MailinglistMailer.ai_mistake_email(@ai_mistake).deliver
        #format.html { redirect_to @ai_mistake.game, notice: 'Your report was successfully sent. Thank you for taking the time to submit it.' }
      #else
        #format.html { render 'new' }
      #end
    #end
  #end

  #private
    ## Never trust parameters from the scary internet, only allow the white list through.
    #def ai_mistake_params
      #params.require(:ai_mistake).permit(:game_id, :log_line_number, :decision, :correct_choice, :options_not_considered)
    #end

end
