class AddColumnToDecks2 < ActiveRecord::Migration
  def change
    add_column :decks, :avatar, :string
  end
end
