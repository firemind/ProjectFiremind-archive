class AddAiStrengthToDuels < ActiveRecord::Migration
  def change
    add_column :duels, :str_ai1, :integer, null: false, default: 6
    add_column :duels, :str_ai2, :integer, null: false, default: 6
  end
end
