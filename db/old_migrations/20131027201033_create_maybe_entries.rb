class CreateMaybeEntries < ActiveRecord::Migration
  def change
    create_table :maybe_entries do |t|
      t.references :deck, index: true, null: false
      t.references :card, index: true, null: false
      t.references :deck_entry_cluster, index: true, null: false
      t.integer :min_amount, null: false
      t.integer :max_amount, null: false

      t.timestamps
    end
  end
end
