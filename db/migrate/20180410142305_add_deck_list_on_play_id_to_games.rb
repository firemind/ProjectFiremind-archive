class AddDeckListOnPlayIdToGames < ActiveRecord::Migration[5.1]
  def change
    add_column :games, :deck_list_on_play_id, :integer
    add_index :games, [:deck_list_on_play_id, :winning_deck_list_id]
    add_index :games, [:deck_list_on_play_id, :losing_deck_list_id]
  end
end
