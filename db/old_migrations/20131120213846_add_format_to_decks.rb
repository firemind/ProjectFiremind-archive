class AddFormatToDecks < ActiveRecord::Migration
  def change
    add_column :decks, :format_id, :integer
  end
end
