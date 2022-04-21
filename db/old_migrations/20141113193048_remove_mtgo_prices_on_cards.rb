class RemoveMtgoPricesOnCards < ActiveRecord::Migration
  def change
    remove_column :cards, :mtgo_price_low
    remove_column :cards, :mtgo_price_med
    remove_column :cards, :mtgo_price_avg
    remove_column :cards, :mtgo_price_high
    add_column :card_prints, :mlbot_sell_price, :integer
  end
end
