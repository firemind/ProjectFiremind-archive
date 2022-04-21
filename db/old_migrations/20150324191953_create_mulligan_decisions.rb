class CreateMulliganDecisions < ActiveRecord::Migration
  def change
    create_table :mulligan_decisions do |t|
      t.integer :dealt_hand_id, null: false
      t.boolean :mulligan, null: false
      t.string :source_ip
      t.integer :user_id

      t.datetime :created_at, null: false
    end
  end
end
