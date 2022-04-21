class CreateCardRequests < ActiveRecord::Migration
  def change
    create_table :card_requests do |t|
      t.integer :user_id
      t.integer :card_id

      t.timestamps
    end
  end
end
