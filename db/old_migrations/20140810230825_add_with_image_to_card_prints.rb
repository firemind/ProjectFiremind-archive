class AddWithImageToCardPrints < ActiveRecord::Migration
  def change
    add_column :card_prints, :with_image, :boolean, null: false, default: false
  end
end
