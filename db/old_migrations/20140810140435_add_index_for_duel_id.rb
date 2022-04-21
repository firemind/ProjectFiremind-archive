class AddIndexForDuelId < ActiveRecord::Migration
  def change
    add_index "games", ["duel_id"], name: "fk_duel"
  end
end
