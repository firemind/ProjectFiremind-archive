class AddFulltextSearchToArchtetypes < ActiveRecord::Migration[5.1]
  def change
    add_index :archetypes, :name, type: :fulltext
    add_index :archetype_aliases, :name, type: :fulltext
  end
end
