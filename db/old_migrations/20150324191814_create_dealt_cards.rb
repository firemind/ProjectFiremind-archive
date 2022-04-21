class CreateDealtCards < ActiveRecord::Migration
  def change
    create_table :dealt_cards do |t|
      t.integer :card_id, null: false
      t.integer :dealt_hand_id, null: false

      t.datetime :created_at, null: false
    end
  end
end
