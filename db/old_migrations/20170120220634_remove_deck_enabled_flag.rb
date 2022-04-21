class RemoveDeckEnabledFlag < ActiveRecord::Migration[5.0]
  def change
    remove_column :decks, :enabled
    add_column :deck_lists, :enabled, :boolean, default: false, null: false
  end
end
