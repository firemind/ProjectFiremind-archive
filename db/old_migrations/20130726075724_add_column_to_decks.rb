class AddColumnToDecks < ActiveRecord::Migration
  def change
    add_column :decks, :colors, :string
  end
end
