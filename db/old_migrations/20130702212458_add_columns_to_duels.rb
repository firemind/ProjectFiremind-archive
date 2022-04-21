class AddColumnsToDuels < ActiveRecord::Migration
  def change
    add_column :duels, :public, :boolean
  end
end
