class AddAutoGeneratedToDecks < ActiveRecord::Migration
  def change
    add_column :decks, :auto_generated, :boolean, default: false, null: false
  end
end
