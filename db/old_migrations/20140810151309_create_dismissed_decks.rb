class CreateDismissedDecks < ActiveRecord::Migration
  def change
    create_table :dismissed_decks do |t|
      t.string :deck_key, null: false
      t.integer :whr_rating, null: false
      t.integer :whr_uncertainty, null: false

      t.timestamps
    end
  end
end
