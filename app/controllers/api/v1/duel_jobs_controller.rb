class Api::V1::DuelJobsController < ApplicationController

  before_action :restrict_access
  respond_to :json

  def pop
    @queue ||= DuelQueue.internal.active.sample
    job_id = @queue.pop
    if job_id
      @duel = Duel.find job_id
      if @duel.state == "waiting"
        @duel.state = "started"
        @duel.assignee_id = @user.id
        @duel.save!
        resp = {
          id: @duel.id,
          games_to_play: @duel.games_to_play,
          state: @duel.state,
          deck1_text: @duel.deck1_text,
          deck2_text: @duel.deck2_text,
          seed: @duel.starting_seed || @duel.id,
          ai1: @queue.ai1,
          ai2: @queue.ai2,
          life: @queue.life,
          str_ai1: @queue.ai1_strength,
          str_ai2: @queue.ai2_strength
        }
        unless @queue.custom_params.blank?
          resp[:custom_params] = custom_params
        end
        if csm = @duel.card_script_submission
          resp[:card_scripts] = [{
            name: csm.card.name,
            config: csm.config,
            script: ""
            #script: csm.script
          }]
        else
          resp[:card_scripts] = []
        end
        render json: resp
        DuelInformWorker.perform_async @duel.id
      else
        ::Rails.logger.debug "!!! duel not in state waiting:: #{@duel.inspect}\n"
        render json: {message: 'Duel not in state waiting'}, status: 404
      end
    else
      ::Rails.logger.debug "!!! no duels in queue"
      render json: {message: 'No duels in queue'}, status: 404
    end
  end

  def post_failure
    duel = Duel.find(params[:id])
    raise "Trying to fail finished duel" if duel.state == 'finished'
    if duel.assignee == @user
      if (msg = params['failure_message']) && msg.length > 0
        duel.failure_message = msg.truncate(65535)
      end
      if duel.requeue_count < 5
        duel.requeue!
      else
        duel.state = 'failed'
        duel.save(validate: false)
      end
      if csm = duel.card_script_submission
        if csm.user
          CsmMailer.check_failed_email(duel).deliver
        end
      end
      DuelInformWorker.perform_async duel.id
      render json: {success: true}
    else
      render json: {success: false}
    end
  end

  def post_success
    duel = Duel.find(params[:id])
    unless duel.state == "finished"
      if duel.assignee == @user && duel.games_to_play == duel.games.count
        duel.state = "finished"
        duel.save(validate: false)
        DuelInformWorker.perform_async duel.id
        if duel.card_script_submission
          PushCardscriptWorker.perform_async(duel.card_script_submission.id)
        end
        duel.inform_success
      end
    end
    render json: {success: true}
  end



end
