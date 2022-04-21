class AddColumnsToDuel7s < ActiveRecord::Migration
  def change
    add_column :duels, :error_acknowledged, :boolean, default: false
  end
end
