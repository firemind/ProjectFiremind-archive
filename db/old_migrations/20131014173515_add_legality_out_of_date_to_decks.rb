class AddLegalityOutOfDateToDecks < ActiveRecord::Migration
  def change
    add_column :decks, :legality_out_of_date, :boolean, null: false, default: true
  end
end
