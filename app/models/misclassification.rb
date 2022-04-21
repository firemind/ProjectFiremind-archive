class Misclassification < ApplicationRecord
  belongs_to :expected, class_name: "Archetype"
  belongs_to :predicted, class_name: "Archetype"
  belongs_to :deck_list
  validates_presence_of :expected, :predicted
end
