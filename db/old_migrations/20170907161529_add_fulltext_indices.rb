class AddFulltextIndices < ActiveRecord::Migration[5.1]
  def change
    add_index :cards, [:name, :ability], type: :fulltext
    add_index :decks, :title, type: :fulltext
  end
end
