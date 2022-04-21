class PlayableHandEntry < ApplicationRecord
  belongs_to :deck
  belongs_to :deck_entry_cluster

  validates_presence_of :min_amount, :max_amount, :deck_entry_cluster, :deck
end
