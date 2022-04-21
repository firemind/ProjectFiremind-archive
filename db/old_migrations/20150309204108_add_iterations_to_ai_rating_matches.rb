class AddIterationsToAiRatingMatches < ActiveRecord::Migration
  def change
    add_column :ai_rating_matches, :iterations, :integer, null: false, default: 1
  end
end
