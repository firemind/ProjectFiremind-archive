class CreateSideboardSuggestions < ActiveRecord::Migration
  def change
    create_table :sideboard_suggestions do |t|
      t.text :sideboard, null: false
      t.float :score, null: false
      t.integer :deck_id, null: false
      t.string :algo, null: false

      t.timestamps null: false
    end
  end
end
