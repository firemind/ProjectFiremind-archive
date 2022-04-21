class AddFormatFlagsToEditions < ActiveRecord::Migration
  def change
    add_column :editions, :modern_legal, :boolean, null: false, default: false
    add_column :editions, :standard_legal, :boolean, null: false, default: false
  end
end
