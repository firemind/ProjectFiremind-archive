class AddLegalToDecks < ActiveRecord::Migration
  def change
    add_column :decks, :legal_in_format, :boolean
  end
end
