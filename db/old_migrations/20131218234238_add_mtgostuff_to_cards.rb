class AddMtgostuffToCards < ActiveRecord::Migration
  def change
    add_column :cards, :mtgo_price_low, :float
    add_column :cards, :mtgo_price_med, :float
    add_column :cards, :mtgo_price_avg, :float
    add_column :cards, :mtgo_price_high, :float
    add_column :cards, :mtgo_id, :integer
  end
end
