class AddDeckListIdToMisclassifications < ActiveRecord::Migration[5.0]
  def change
    add_column :misclassifications, :deck_list_id, :integer
  end
end
