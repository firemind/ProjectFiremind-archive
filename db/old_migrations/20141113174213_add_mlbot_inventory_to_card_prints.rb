class AddMlbotInventoryToCardPrints < ActiveRecord::Migration
  def change
    add_column :card_prints, :mlbot_inventory, :integer
  end
end
