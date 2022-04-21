class Ruling < ApplicationRecord
  belongs_to :card
  validates_presence_of :card, :date, :text
end
