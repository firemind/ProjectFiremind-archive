class AiMistake < ApplicationRecord
  belongs_to :game
  belongs_to :user
  validates_presence_of :game
  validates_presence_of :user
end
