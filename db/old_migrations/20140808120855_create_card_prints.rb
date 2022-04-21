class CreateCardPrints < ActiveRecord::Migration
  def change
    create_table :card_prints do |t|
      t.integer :card_id
      t.integer :edition_id
      t.string :rarity
      t.text :flavor_text
      t.string :artist
      t.string :variation
      t.float :price_low
      t.float :price_mid
      t.float :price_high
      t.float :mtgo_price_low
      t.float :mtgo_price_avg
      t.float :mtgo_price_med
      t.float :mtgo_price_high
      t.integer :mtgo_id
      t.float :mtgo_buying_override
      t.float :mtgo_selling_override
      t.string :mlbot_name
      t.integer :mtgo_buying_quantity

      t.timestamps
    end
  end
end
