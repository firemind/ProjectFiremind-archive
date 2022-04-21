class AddColumnToDeckEntries < ActiveRecord::Migration
  def change
    add_column :deck_entries, :group_type, :string
  end
end
