class RemoveDecksFormats < ActiveRecord::Migration
  def change
    drop_table :decks_formats
  end
end
