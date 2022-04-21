class CreateDealtHands < ActiveRecord::Migration
  def change
    create_table :dealt_hands do |t|
      t.integer :deck_list_id, null: false

      t.datetime :created_at, null: false
    end
  end
end
