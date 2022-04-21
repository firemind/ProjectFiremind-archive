class Add < ActiveRecord::Migration
  def change
    remove_index :decks_formats, [:deck_id, :format_id]
    add_index(:decks_formats, [:deck_id, :format_id], :unique => true)
  end
end
