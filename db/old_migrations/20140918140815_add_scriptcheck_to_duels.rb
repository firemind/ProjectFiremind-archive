class AddScriptcheckToDuels < ActiveRecord::Migration
  def change
    add_column :duels, :scriptcheck, :boolean, null: false, default: false
  end
end
