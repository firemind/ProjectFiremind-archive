class MakePtStrings < ActiveRecord::Migration
  def change
    change_column :cards, :power, :string
    change_column :cards, :toughness, :string
  end
end
