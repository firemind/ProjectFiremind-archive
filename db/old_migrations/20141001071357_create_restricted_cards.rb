class CreateRestrictedCards < ActiveRecord::Migration
  def change
    create_table :restricted_cards do |t|
      t.integer :card_id, null: false
      t.integer :format_id, null: false
      t.integer :limit, limit: 2
    end
  end
end
