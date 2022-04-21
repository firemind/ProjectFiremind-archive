class NotImplementableReason < ApplicationRecord
  belongs_to :user
  validates_presence_of :name
  validates_uniqueness_of :name
  validates_presence_of :user
  has_and_belongs_to_many :cards, -> { distinct }, dependent: :restrict_with_erro

  validate do
    if persisted? && name_changed? && cards.size > 0
      errors.add :name, "can't be changed once it is added to cards"
    end
  end

  def name=(new_name)
    write_attribute(:name, self.class.escape_name(new_name))
  end

  def self.escape_name(name)
    name.downcase.gsub(/[^a-z0-9-]/, '-')
  end
end
