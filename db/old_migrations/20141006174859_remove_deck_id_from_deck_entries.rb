class RemoveDeckIdFromDeckEntries < ActiveRecord::Migration
  def change
    remove_column :deck_entries, :deck_id
    remove_column :deck_entries, :deck_revision_id
    DeckEntry.where(deck_list_id: nil).destroy_all
  end
end
