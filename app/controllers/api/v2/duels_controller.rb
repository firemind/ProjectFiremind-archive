class Api::V2::DuelsController < Api::V2::BaseController

  include DuelsHelper

  def asset_path(args)
    ActionController::Base.helpers.asset_path(args)
  end

  def image_url(args)
    ActionController::Base.helpers.image_url(args)
  end


  def my
    duels = current_user.duels.includes({deck_list1: :archetype, deck_list2: :archetype})
    if (id = params['last_id'].to_i) > 0
      duels = duels.where("id < ?", id)
    end
    render json: duels.last(5).map{|d|
      {
        id: d.id,
        games_played: d.games_played,
        games_to_play: d.games_played,
        format: d.format.to_s,
        winner_name: d.winner.to_s,
        loser_name: d.loser.to_s,
        duel_link: url_for(d),
        winner_img: deck_list_image_url(d.winner),
        progress: ( d.games_played.to_i / d.games_to_play.to_f * 100).round
      }
    }
  end
end
