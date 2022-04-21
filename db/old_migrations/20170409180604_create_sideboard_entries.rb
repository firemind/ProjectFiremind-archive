class CreateSideboardEntries < ActiveRecord::Migration[5.0]
  def change
    create_table :sideboard_entries do |t|
      t.integer "card_id"
      t.integer "amount"
      t.string  "group_type"
      t.integer "deck_id"
      t.index ["card_id", "deck_id"], unique: true
      t.index ["card_id"]
      t.index ["deck_id"]

      t.timestamps
    end
  end
end
