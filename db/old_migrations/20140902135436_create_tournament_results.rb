class CreateTournamentResults < ActiveRecord::Migration
  def change
    create_table :tournament_results do |t|
      t.integer :tournament_id
      t.integer :wins
      t.integer :losses
      t.string :mtgo_nick
      t.integer :mtggf_id

      t.timestamps
    end
  end
end
