class CreateRulings < ActiveRecord::Migration
  def change
    create_table :rulings do |t|
      t.integer :card_id
      t.text :text
      t.date :date

      t.timestamps
    end
  end
end
