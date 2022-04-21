class Edition < ApplicationRecord
  has_many :card_prints, dependent: :destroy
  has_many :cards, through: :card_prints
  has_and_belongs_to_many :formats

  validates_presence_of :short
  validates_uniqueness_of :short, :name

  def to_s
    "#{short} - #{name}"
  end

  def as_json(options={})
    {
      id: id,
      short: short,
      name: name
    }
  end

end
