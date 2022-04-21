class AddEloRatingToRatings < ActiveRecord::Migration[5.1]
  def change
    add_column :ratings, :elo_rating, :integer
  end
end
