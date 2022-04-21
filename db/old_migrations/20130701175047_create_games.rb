class CreateGames < ActiveRecord::Migration
  def change
    create_table :games do |t|
      t.integer :duel_id
      t.boolean :win_deck1
      t.time :play_time
      t.integer :game_number

      t.timestamps
    end
  end
end
