class CardScriptClaim < ApplicationRecord
  belongs_to :user
  belongs_to :card
  validates_presence_of :user, :card
  validates_uniqueness_of :card, scope: :user
end
