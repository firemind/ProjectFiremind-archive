class AddSysuserIdToAiRatingMatches < ActiveRecord::Migration
  def change
    add_column :ai_rating_matches, :sysuser_id, :integer, null: false
  end
end
