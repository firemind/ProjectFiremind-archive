class CardScriptSubmissionsController < ApplicationController
  before_action :set_card_script_submission, only: [:show ]
  before_action :authenticate_user!, only: [:my]

  # GET /card_script_submissions/new
  def new
    @card_script_submission = CardScriptSubmission.new
    if params[:card_id] && card = Card.find(params[:card_id])
      @card_script_submission.card = card
      @card_script_submission.config= card.missing_config_script
      @card_script_submission.script= card.missing_groovy_script
    end
  end

  def show
  end

  def my
    @csms = current_user.card_script_submissions.includes(:card)
  end

  # POST /card_script_submissions
  # POST /card_script_submissions.json
  def create
    @card_script_submission = CardScriptSubmission.new(card_script_submission_params)
    @card_script_submission.user = current_user
    @card_script_submission.config.encode!("UTF-8") if @card_script_submission.config
    @card_script_submission.script.encode!("UTF-8") if @card_script_submission.script
    respond_to do |format|
      if (@card_script_submission.card || @card_script_submission.is_token ) && @card_script_submission.save
        if @card_script_submission.can_be_tested?
          d = @card_script_submission.create_check_duel!(User.where(sysuser:true).first)
          format.html { redirect_to duel_path(d), notice: 'Card Script was successfully submitted. We will run a test duel now and inform you about success or failure.' }
        else
          PushCardscriptWorker.perform_async(@card_script_submission.id)
          format.html { redirect_to root_path, notice: 'Card Script was successfully submitted.' }
        end
      else
        flash[:error] = "Select a valid card name or make the card a token" unless @card_script_submission.card || @card_script_submission.is_token
        format.html { render 'new' }
      end
    end
  end

  def force_submit
    @csm = CardScriptSubmission.find(params[:id])
    respond_to do |format|
      if @csm.user == current_user
        unless @csm.pushed
          PushCardscriptWorker.perform_async(@csm.id)
          format.html { redirect_to @csm, notice: 'It is being pushed. Refresh after a couple of seconds.' }
        else
          format.html { redirect_to @csm, notice: 'Already pushed' }
        end
      else
        format.html { redirect_to @csm, notice: 'No permissions' }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_card_script_submission
      @card_script_submission = CardScriptSubmission.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def card_script_submission_params
      params.require(:card_script_submission).permit(:card_id, :config, :script, :comment, :card_name, :is_token)
    end

end
