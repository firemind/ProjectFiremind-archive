class AddFreeformToDuels < ActiveRecord::Migration
  def change
    add_column :duels, :freeform, :boolean, null: false, default: false
  end
end
