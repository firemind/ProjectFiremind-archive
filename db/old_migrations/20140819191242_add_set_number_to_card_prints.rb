class AddSetNumberToCardPrints < ActiveRecord::Migration
  def change
    add_column :card_prints, :nr_in_set, :integer
  end
end
