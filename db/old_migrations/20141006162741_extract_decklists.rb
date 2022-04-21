class ExtractDecklists < ActiveRecord::Migration
  def change
    add_column :deck_entries, :deck_list_id, :integer
    add_index "deck_entries", ["deck_list_id"], name: "ix_deck_list_id", using: :btree
    change_column :deck_entries, :deck_revision_id, :integer, null: false, default: 1
    Deck.all.find_each(batch_size: 10) do |d|
      d.decklist= d.old_decklist
      d.save(validate: false)
    end
  end
end
