class RenameGamesColumn < ActiveRecord::Migration
  def change
    rename_column :duels, :games, :games_to_play
    change_column :duels, :games_to_play, :integer, null: false
  end
end
