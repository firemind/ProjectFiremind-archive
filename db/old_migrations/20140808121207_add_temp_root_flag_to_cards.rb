class AddTempRootFlagToCards < ActiveRecord::Migration
  def change
    add_column :cards, :temp_root_flag, :boolean, default: false, null: false
  end
end
