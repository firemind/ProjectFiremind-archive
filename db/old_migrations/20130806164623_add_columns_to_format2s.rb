class AddColumnsToFormat2s < ActiveRecord::Migration
  def change
    add_column :formats, :max_copies, :integer, null: false, default: 4
  end
end
