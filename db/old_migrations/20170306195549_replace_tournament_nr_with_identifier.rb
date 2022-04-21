class ReplaceTournamentNrWithIdentifier < ActiveRecord::Migration[5.0]
  def change
    rename_column :tournaments, :nr, :identifier
    change_column :tournaments, :identifier, :string
  end
end
