class SideboardPlan < ApplicationRecord
  belongs_to :deck
  belongs_to :deck_list
  belongs_to :archetype
  validates_uniqueness_of :archetype, scope: [:deck, :deck_list]
  has_many :sideboard_ins, dependent: :destroy
  has_many :sideboard_outs, dependent: :destroy
  validates_presence_of :archetype
end
