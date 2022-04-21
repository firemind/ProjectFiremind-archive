class CreateAirmDecks < ActiveRecord::Migration
  def change
    create_table :airm_decks do |t|
      t.integer :deck_list1_id, null: false
      t.integer :deck_list2_id, null: false
      t.integer :rounds, null: false

      t.timestamps
    end
  end
end
