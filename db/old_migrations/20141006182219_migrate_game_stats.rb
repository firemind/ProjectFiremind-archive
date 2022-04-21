class MigrateGameStats < ActiveRecord::Migration
  def change
    Game.joins(:duel).where(win_deck1: true).update_all("winning_deck_list_id = duels.deck_list1_id, losing_deck_list_id = duels.deck_list2_id")
    Game.joins(:duel).where(win_deck1: false).update_all("winning_deck_list_id = duels.deck_list2_id, losing_deck_list_id = duels.deck_list1_id")
  end
end
