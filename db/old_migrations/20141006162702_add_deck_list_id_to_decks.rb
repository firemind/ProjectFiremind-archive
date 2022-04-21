class AddDeckListIdToDecks < ActiveRecord::Migration
  def change
    add_column :decks, :deck_list_id, :integer, null: false
  end
end
