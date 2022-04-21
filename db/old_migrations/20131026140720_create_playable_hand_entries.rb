class CreatePlayableHandEntries < ActiveRecord::Migration
  def change
    create_table :playable_hand_entries do |t|
      t.references :deck, null: false
      t.references :deck_entry_cluster, null: false
      t.integer :min_amount, null: false
      t.integer :max_amount, null: false

      t.timestamps
    end
  end
end
