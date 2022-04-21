class DeckClassification < ApplicationRecord
  include Decklistable
  belongs_to :format

  validates_presence_of :deck_list, :source_ip
end
