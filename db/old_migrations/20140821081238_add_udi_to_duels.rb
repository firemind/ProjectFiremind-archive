class AddUdiToDuels < ActiveRecord::Migration
  def change
    add_column :duels, :deck1_udi, :string
    add_column :duels, :deck2_udi, :string
  end
end
