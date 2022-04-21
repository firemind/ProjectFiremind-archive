class UpdatePriceChanges < ActiveRecord::Migration
  def change
    ActiveRecord::Base.connection.execute("TRUNCATE price_changes")
    rename_column :price_changes, :card_id, :card_print_id
    add_column :price_changes, :source, :string
  end
end
