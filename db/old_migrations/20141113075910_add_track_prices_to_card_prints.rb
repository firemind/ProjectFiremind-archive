class AddTrackPricesToCardPrints < ActiveRecord::Migration
  def change
    add_column :card_prints, :track_prices, :boolean, null: false, default: false
  end
end
