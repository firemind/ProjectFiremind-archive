class AddMetaIdToSideboardingSuggestions < ActiveRecord::Migration
  def change
    add_column :sideboard_suggestions, :meta_id, :integer
  end
end
