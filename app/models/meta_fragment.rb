class MetaFragment < ApplicationRecord
  belongs_to :meta
  belongs_to :archetype
  validates_presence_of :meta, :archetype, :occurances
end
