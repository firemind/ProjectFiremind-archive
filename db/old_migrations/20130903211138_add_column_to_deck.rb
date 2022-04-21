class AddColumnToDeck < ActiveRecord::Migration
  def change
    add_column :decks, :enabled, :boolean, default: false
  end
end
