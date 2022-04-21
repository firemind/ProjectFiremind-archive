class AddColumnToRatings < ActiveRecord::Migration
  def change
    add_column :ratings, :whr_rating, :integer
    add_column :ratings, :whr_uncertainty, :integer
  end
end
