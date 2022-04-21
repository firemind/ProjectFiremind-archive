class AddMtgoFlagToEditions < ActiveRecord::Migration
  def change
    add_column :editions, :mtgo, :boolean, null: false, default: true
  end
end
