class Api::V1::GamesController < ApplicationController

  before_action :restrict_access
  respond_to :json

  def create
    duel = Duel.find(params[:duel_job_id])
    if duel.assignee == @user
      if duel.started?
        duel.magarena_version_major ||= params[:magarena_version_major]
        duel.magarena_version_minor ||= params[:magarena_version_minor]
        if duel.magarena_version_major == params[:magarena_version_major].to_i && duel.magarena_version_minor == params[:magarena_version_minor].to_i
          if params[:win_deck1].to_s == 'true'
            winner = duel.deck_list1_id
            loser = duel.deck_list2_id
          elsif params[:win_deck1].to_s == 'false'
            winner = duel.deck_list2_id
            loser = duel.deck_list1_id
          else
            render json: {error: "Not a valid value for win_deck1 #{params[:win_deck1]}"} , status: :unprocessable_entity
            return
          end
          g = duel.games.build({
            game_number: params[:game_number],
            play_time: params[:play_time],
            winning_deck_list_id: winner,
            losing_deck_list_id: loser,
          })
          g.save!
          g.updated_at = Time.now # touch record to ensure proper caching
          #if duel.games_to_play == duel.games_played
            #duel.state = 'finished'
          #end
          if duel.save
            dst = LOGFILE_BASEDIR+g.log_path
            FileUtils.mkdir_p(File.dirname(dst))
            File.open(dst, 'w') { |file| file.write(params['log'].encode('utf-8')) }
            ParseGameLogWorker.perform_async g.id
            DuelInformWorker.perform_async duel.id
            render json: {message: "success"}
          else
            ::Rails.logger.debug "!!! errors:: #{g.errors.inspect}\n"
            ::Rails.logger.debug "!!! errors:: #{duel.errors.inspect}\n"
            render json: {game: g.errors, duel: duel.errors} , status: :unprocessable_entity
          end
        else
          render json: {message: "Magarena Version doesn't match last games"}, status: :unprocessable_entity
        end
      else
        render json: {message: "Duel is not in state started"}, status: :unprocessable_entity
      end
    else
      render json: {message: "Duel is not being proccessed by you"}, status: 403
    end
  end
end
