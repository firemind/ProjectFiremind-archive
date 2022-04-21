class AddFormatsAssoc < ActiveRecord::Migration
  def change
    create_table :decks_formats, :id => false do |t|
      t.references :deck
      t.references :format
    end
    add_index :decks_formats, [:deck_id, :format_id]
    add_index :decks_formats, :format_id
  end
end
