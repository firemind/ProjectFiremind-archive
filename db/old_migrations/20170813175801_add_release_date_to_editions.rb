class AddReleaseDateToEditions < ActiveRecord::Migration[5.1]
  def change
    add_column :editions, :release_date, :date
  end
end
