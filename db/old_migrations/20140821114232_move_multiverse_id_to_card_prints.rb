class MoveMultiverseIdToCardPrints < ActiveRecord::Migration
  def change
    remove_column :cards, :multiverse_id
    add_column :card_prints, :multiverse_id, :integer
  end
end
