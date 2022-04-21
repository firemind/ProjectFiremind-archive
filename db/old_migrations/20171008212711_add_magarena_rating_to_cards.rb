class AddMagarenaRatingToCards < ActiveRecord::Migration[5.1]
  def change
    add_column :cards, :magarena_rating, :float
    Card.enabled.find_each do |c|
      c.calc_magarena_rating!
    end
  end
end
