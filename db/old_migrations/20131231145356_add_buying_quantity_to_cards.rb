class AddBuyingQuantityToCards < ActiveRecord::Migration
  def change
    add_column :cards, :mtgo_buying_quantity, :integer
  end
end
