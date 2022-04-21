class RemoveObsoleteCardColumns < ActiveRecord::Migration
  def change

    remove_column :cards, :ruling
    remove_column :cards, :edition_id
    remove_column :cards, :rarity
    remove_column :cards, :flavor_text
    remove_column :cards, :artist
    remove_column :cards, :variation
    remove_column :cards, :price_low
    remove_column :cards, :price_mid
    remove_column :cards, :price_high
    remove_column :cards, :mtgo_price_low
    remove_column :cards, :mtgo_price_avg
    remove_column :cards, :mtgo_price_med
    remove_column :cards, :mtgo_price_high
    remove_column :cards, :mtgo_id
    remove_column :cards, :mtgo_buying_override
    remove_column :cards, :mtgo_selling_override
    remove_column :cards, :mlbot_name
    remove_column :cards, :mtgo_buying_quantity
    remove_column :cards, :converted_manacost
  end
end
