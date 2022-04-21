class AddColumnsToDecks < ActiveRecord::Migration
  def change
    add_column :decks, :public, :boolean, default: true
  end
end
