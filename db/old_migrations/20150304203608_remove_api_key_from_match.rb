class RemoveApiKeyFromMatch < ActiveRecord::Migration
  def change
    remove_column :ai_rating_matches, :api_key
  end
end
