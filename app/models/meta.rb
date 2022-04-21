class Meta < ApplicationRecord
  belongs_to :format
  belongs_to :user
  has_many :meta_fragments
  has_many :archetypes, through: :meta_fragments
  validates_presence_of :format, :name
  accepts_nested_attributes_for :meta_fragments, allow_destroy: true

  def percentage_map
    total_occ = meta_fragments.sum(:occurances)
    total_occ = Hash[meta_fragments.map{|mf| [mf.archetype_id, mf.occurances.to_f/total_occ]}]
  end

  def to_s
    name
  end
end
