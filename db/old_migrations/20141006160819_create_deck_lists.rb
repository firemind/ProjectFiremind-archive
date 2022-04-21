class CreateDeckLists < ActiveRecord::Migration
  def change
    create_table :deck_lists, force: true do |t|
      t.string :udi, limit: 40
      t.integer :archetype_id
      t.string :colors

      t.timestamps
    end
    add_index :deck_lists, ["udi"], name: "ix_udi", length: {"udi"=>10}, using: :btree
  end
end
