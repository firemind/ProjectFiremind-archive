class CreateArchetypeStaples < ActiveRecord::Migration
  def change
    create_table :archetype_staples, force: true do |t|
      t.integer :archetype_id, null: false
      t.integer :card_id, null: false
      t.integer :relevance, null: false, default: 1
    end
    add_index "archetype_staples", ["archetype_id", "card_id"], unique: true, using: :btree
  end
end
