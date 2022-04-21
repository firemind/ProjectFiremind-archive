class AddFulltextOnJustNameToCards < ActiveRecord::Migration[5.1]
  def change
    add_index :cards, :name, type: :fulltext
  end
end
