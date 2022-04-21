class TrackPriceChanges < ActiveRecord::Migration
  def change
    add_column :decks, :track_prices, :boolean, null: false, default: false
    create_table :price_changes do |t|
      t.integer :card_id, null: false
      t.string :price_type, null: false
      t.float :original_value, null: false
      t.float :new_value, null: false
      t.float :change_in_percent, null: false
      t.timestamps
    end
  end
end
