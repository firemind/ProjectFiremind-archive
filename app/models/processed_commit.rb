class ProcessedCommit < ApplicationRecord
  validates_presence_of :name

  def self.last
    self.order("created_at").last
  end

  def self.log(name)
    self.create(name: name)
  end
end
