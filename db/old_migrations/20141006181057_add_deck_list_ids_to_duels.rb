class AddDeckListIdsToDuels < ActiveRecord::Migration
  def change
    add_column :duels, :deck_list1_id, :integer
    add_column :duels, :deck_list2_id, :integer
    add_index "duels", ["deck_list1_id"], name: "ix_deck_list1_id", using: :btree
    add_index "duels", ["deck_list2_id"], name: "ix_deck_list2_id", using: :btree
    add_column :games, :winning_deck_list_id, :integer
    add_column :games, :losing_deck_list_id, :integer
    add_index "games", ["winning_deck_list_id"], name: "ix_winning_deck_list_id", using: :btree
    add_index "games", ["losing_deck_list_id"], name: "ix_losing_deck_list_id", using: :btree
    Duel.joins(:deck1).update_all("deck_list1_id = decks.deck_list_id")
    Duel.joins(:deck2).update_all("deck_list2_id = decks.deck_list_id")
  end
end
