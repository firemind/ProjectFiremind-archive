class AddPriceOverridesToCards < ActiveRecord::Migration
  def change
    add_column :cards, :mtgo_buying_override, :float
    add_column :cards, :mtgo_selling_override, :float
  end
end
