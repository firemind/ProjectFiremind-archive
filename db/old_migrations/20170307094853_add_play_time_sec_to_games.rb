class AddPlayTimeSecToGames < ActiveRecord::Migration[5.0]
  def change
    add_column :games, :play_time_sec, :integer
    Game.update_all("play_time_sec = TIMESTAMPDIFF(SECOND, '2000-01-01 00:00:00', DATE_FORMAT(play_time, '2000-01-01 %H:%i:%s'))")
    change_column :games, :play_time_sec, :integer, null: false
    remove_column :games, :play_time
  end
end
