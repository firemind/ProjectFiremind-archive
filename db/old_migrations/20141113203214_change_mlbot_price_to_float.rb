class ChangeMlbotPriceToFloat < ActiveRecord::Migration
  def change
    change_column :card_prints, :mlbot_sell_price, :float
  end
end
