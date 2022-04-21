class AddTournamentResultIdToDecks < ActiveRecord::Migration
  def change
    add_column :decks, :tournament_result_id, :integer
  end
end
