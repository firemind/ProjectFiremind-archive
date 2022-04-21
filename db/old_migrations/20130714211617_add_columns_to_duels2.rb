class AddColumnsToDuels2 < ActiveRecord::Migration
  def up
    add_column :duels, :deck1_revision, :integer
    add_column :duels, :deck2_revision, :integer
  end
  def down
    remove_column :duels, :deck_revision, :integer
  end
end
