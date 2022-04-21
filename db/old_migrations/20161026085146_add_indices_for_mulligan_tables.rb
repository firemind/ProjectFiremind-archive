class AddIndicesForMulliganTables < ActiveRecord::Migration
  def change
    add_index :dealt_cards, :dealt_hand_id
    add_index :dealt_hands, :deck_list_id
    add_index :mulligan_decisions, :dealt_hand_id

  end
end
