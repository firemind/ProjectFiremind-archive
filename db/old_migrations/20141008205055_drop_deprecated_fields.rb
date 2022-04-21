class DropDeprecatedFields < ActiveRecord::Migration
  def change
    remove_column :decks, :colors
    remove_column :decks, :digest
    remove_column :ratings, :deck_id
    remove_column :ratings, :deck_revision
    remove_column :duels, :deck1_id
    remove_column :duels, :deck2_id
    remove_column :duels, :deck1_revision
    remove_column :duels, :deck2_revision
    remove_column :duels, :deck1_udi
    remove_column :duels, :deck1_udi_hash
    remove_column :duels, :deck2_udi
    remove_column :duels, :deck2_udi_hash
    remove_column :duels, :games_played
    remove_column :games, :win_deck1
    remove_column :versions, :revision
  end
end
