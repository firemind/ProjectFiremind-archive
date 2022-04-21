class AddAiToDuels < ActiveRecord::Migration
  def change
    add_column :duels, :ai1, :string
    add_column :duels, :ai2, :string
  end
end
