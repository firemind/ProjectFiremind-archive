class CreateDecks < ActiveRecord::Migration
  def change
    create_table :decks do |t|
      t.string :title
      t.text :description
      t.integer :author_id

      t.timestamps
    end
    create_table :deck_entries do |t|
      t.integer :card_id
      t.integer :deck_id
      t.integer :amount
    end
  end
end
