class AddHasThumbToCardPrints < ActiveRecord::Migration[5.0]
  def change
    add_column :card_prints, :has_thumb, :boolean, null: false, default: false
    CardPrint.where(has_crop: true).update_all(has_thumb: true)
  end
end
