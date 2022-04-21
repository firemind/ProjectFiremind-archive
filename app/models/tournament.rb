class Tournament < ApplicationRecord
  belongs_to :format
  has_many :tournament_results, dependent: :destroy
  accepts_nested_attributes_for :tournament_results, allow_destroy: true

  def to_s
    "#{identifier} #{format} #{tournament_type}"
  end
end
