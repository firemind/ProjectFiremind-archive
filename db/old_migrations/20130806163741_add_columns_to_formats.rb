class AddColumnsToFormats < ActiveRecord::Migration
  def change
    add_column :formats, :min_deck_size, :integer, null: false, default: 0
    add_column :formats, :max_deck_size, :integer
  end
end
