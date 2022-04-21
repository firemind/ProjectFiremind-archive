class DeckEntryCluster < ApplicationRecord
  belongs_to :deck
  has_and_belongs_to_many :deck_entries

  validates_presence_of :name, :deck

  def to_s
    name
  end
end
