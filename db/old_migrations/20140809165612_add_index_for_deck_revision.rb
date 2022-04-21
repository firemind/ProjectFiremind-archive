class AddIndexForDeckRevision < ActiveRecord::Migration
  def change
    add_index "duels", ["deck1_id", "deck1_revision"], name: "fk_deck1_revision"
    add_index "duels", ["deck2_id", "deck2_revision"], name: "fk_deck2_revision"
  end
end
