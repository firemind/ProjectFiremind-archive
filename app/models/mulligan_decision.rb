class MulliganDecision < ApplicationRecord
  belongs_to :dealt_hand
  belongs_to :user

  def source
    user || source_ip
  end
end
