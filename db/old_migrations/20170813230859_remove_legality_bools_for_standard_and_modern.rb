class RemoveLegalityBoolsForStandardAndModern < ActiveRecord::Migration[5.1]
  def change
    remove_column :editions, :standard_legal
    remove_column :editions, :modern_legal
  end
end
