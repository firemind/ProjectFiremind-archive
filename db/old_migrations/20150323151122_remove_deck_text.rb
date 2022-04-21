class RemoveDeckText < ActiveRecord::Migration
  def change
    remove_column :duels, :deck1_text
    remove_column :duels, :deck2_text
  end
end
