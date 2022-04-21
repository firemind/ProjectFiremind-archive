class AddIndexesToGames < ActiveRecord::Migration
  def change
    add_index "duels", ["deck1_id"], name: "fk_deck1"
    add_index "duels", ["deck2_id"], name: "fk_deck2"
  end
end
