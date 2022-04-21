class AddCardDeckListUniqueIndex < ActiveRecord::Migration[5.0]
  def change
    add_index(:deck_entries, [:card_id, :deck_list_id], unique: true)
  end
end
