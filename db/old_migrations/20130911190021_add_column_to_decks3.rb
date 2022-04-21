class AddColumnToDecks3 < ActiveRecord::Migration
  def change
    add_column :decks, :digest, :string
  end
end
