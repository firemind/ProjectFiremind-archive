class CreateDuels < ActiveRecord::Migration
  def change
    create_table :duels do |t|
      t.integer :games
      t.integer :deck1_id
      t.integer :deck2_id
      t.integer :user_id
      t.text :deck1_text
      t.text :deck2_text
      t.string :state
      t.integer :games_played
      t.integer :wins_deck1

      t.timestamps
    end
  end
end
