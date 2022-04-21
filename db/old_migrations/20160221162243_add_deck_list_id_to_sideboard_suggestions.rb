class AddDeckListIdToSideboardSuggestions < ActiveRecord::Migration
  def change
    SideboardSuggestion.destroy_all
    add_column :sideboard_suggestions, :deck_list_id, :integer, null: false
  end
end
