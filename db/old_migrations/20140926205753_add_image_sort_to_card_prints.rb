class AddImageSortToCardPrints < ActiveRecord::Migration
  def change
    add_column :card_prints, :img_sort, :integer, null: false, default: 0
  end
end
