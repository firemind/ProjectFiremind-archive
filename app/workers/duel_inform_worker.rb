class DuelInformWorker
  include Sidekiq::Worker
  include Rails.application.routes.url_helpers

  def perform(duel_id)
    duel=Duel.find(duel_id)
    broadcast_duel duel
  end

  def broadcast_duel(duel)
    dq = duel.duel_queue

    DuelQueuesChannel.broadcast_to(
      dq,
      duel_id: duel.id,
      duel_state: dq.state,
      url: box_duel_path(duel)
    )
  end
end
