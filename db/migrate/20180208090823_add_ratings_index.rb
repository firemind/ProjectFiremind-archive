class AddRatingsIndex < ActiveRecord::Migration[5.1]
  def change
    if Rails.env.test?
      Rating.delete_all
    end
    add_index :ratings, [:format_id, :deck_list_id], unique: true
  end
end
