class AddMultiverseIdToCards < ActiveRecord::Migration
  def change
    add_column :cards, :multiverse_id, :integer
    remove_column :cards, :nr_in_set, :integer
  end
end
