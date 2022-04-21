class DropUnusedWinsDeck1Column < ActiveRecord::Migration[5.1]
  def change
    remove_column :duels, :wins_deck1
  end
end
