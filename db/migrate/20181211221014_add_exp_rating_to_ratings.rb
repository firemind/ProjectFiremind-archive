class AddExpRatingToRatings < ActiveRecord::Migration[5.1]
  def change
    add_column :ratings, :exp_rating, :float
  end
end
