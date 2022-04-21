class RemoveUnusedLegalityFieldsOnDecks < ActiveRecord::Migration
  def change
    remove_column :decks, :legality_out_of_date
    remove_column :decks, :legal_in_format
  end
end
