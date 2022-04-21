class SideboardSuggestion < ApplicationRecord
  belongs_to :deck
  belongs_to :deck_list
  belongs_to :meta
  validates_presence_of :deck

  def entries
    @entries ||= sideboard.split("\n").map {|line| 
      s = line.split(' ')
      [s[0].to_i, Card.find_by_name(s[1..-1].join(' '))]
    }
  end
end
