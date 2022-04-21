class MigrateRatingsToDecklists < ActiveRecord::Migration
  def change
    add_column :ratings, :deck_list_id, :integer
    add_index "ratings", ["deck_list_id"], name: "ix_deck_list_id", using: :btree
    Rating.joins(:deck).update_all("ratings.deck_list_id = decks.deck_list_id")
  end
end
