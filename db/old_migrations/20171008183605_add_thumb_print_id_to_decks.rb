class AddThumbPrintIdToDecks < ActiveRecord::Migration[5.1]
  def change
    add_column :decks, :thumb_print_id, :integer
  end
end
