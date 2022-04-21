class AddDeckListGamesCounterCache < ActiveRecord::Migration[5.1]
  def change
    add_column :deck_lists, :won_games_count, :integer, null: false, default: 0
    add_column :deck_lists, :lost_games_count, :integer, null: false, default: 0
    DeckList.reset_column_information
    DeckList.all.pluck(:id).each do |id|
      DeckList.reset_counters(id, :won_games)
      DeckList.reset_counters(id, :lost_games)
    end
  end
end
