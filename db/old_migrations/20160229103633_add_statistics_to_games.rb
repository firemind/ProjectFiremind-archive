class AddStatisticsToGames < ActiveRecord::Migration
  def change
    add_column :games, :win_on_turn, :integer
    add_column :games, :winner_decision_count, :integer
    add_column :games, :winner_action_count, :integer
    add_column :games, :loser_decision_count, :integer
    add_column :games, :loser_action_count, :integer
  end
end
