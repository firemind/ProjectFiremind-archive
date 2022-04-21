class AddDefaultsForAvatar < ActiveRecord::Migration
  def change
    change_column :decks, :avatar, :string, null: false, default: 'avatar06.png'
  end
end
