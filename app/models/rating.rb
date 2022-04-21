class Rating < ApplicationRecord
  belongs_to :format

  belongs_to :deck_list

  #trust index to do this to improve performance
  #validates_uniqueness_of :format, scope: [:deck_list_id]

  validates_presence_of :deck_list, :format

  def to_s
    whr_rating.to_s
  end

  scope :highest_in, ->(format) do
    dl_ids = format.decks.active.legal.select(:deck_list_id)
    format.ratings.where("deck_list_id in (#{dl_ids.to_sql})").order("whr_rating desc")
  end

  # removed for performance since legality should no longer change because of rotating formats
  #validate do
    #unless deck_list.legal_in?(format)
      #self.errors.add(:deck_list_id, "Not legal in #{format.to_s}")
    #end
  #end

end
