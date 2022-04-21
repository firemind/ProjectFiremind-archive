class DismissedDecks < ApplicationRecord
  validates_presence_of :deck_key, :whr_rating, :whr_uncertainty
end
