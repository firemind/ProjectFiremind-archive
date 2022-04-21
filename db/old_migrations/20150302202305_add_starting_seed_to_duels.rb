class AddStartingSeedToDuels < ActiveRecord::Migration
  def change
    add_column :duels, :starting_seed, :integer
  end
end
