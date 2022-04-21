class AddWinnerAndLoserIndexToGames < ActiveRecord::Migration[5.1]
  def change
    add_index :games, [:winning_deck_list_id, :losing_deck_list_id]
  end
end
