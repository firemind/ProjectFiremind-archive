class DuelQueuesChannel < ApplicationCable::Channel
  def subscribed
    dq = DuelQueue.find params[:id]

    if dq.user && dq.user != current_user
      reject_unauthorized_connection
    else
      stream_for dq
    end
  end

end
