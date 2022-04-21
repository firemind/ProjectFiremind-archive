class RemoveRevisionAndVersionsFromDecks < ActiveRecord::Migration
  def change
    Version.where(item_type: "Deck").delete_all
    remove_column :decks, :revision
  end
end
