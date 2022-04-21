class AddColumnToDuels3 < ActiveRecord::Migration
  def change
    add_column :duels, :failure_message, :text
  end
end
