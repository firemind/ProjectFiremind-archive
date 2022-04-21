class AddFormatStateIndexToDuels < ActiveRecord::Migration[5.1]
  def change
    add_index :duels, [:format_id, :state]
  end
end
