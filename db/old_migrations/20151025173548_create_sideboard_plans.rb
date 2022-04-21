class CreateSideboardPlans < ActiveRecord::Migration
  def change
    create_table :sideboard_plans do |t|
      t.integer :archetype_id, null: false
      t.integer :deck_id, null: false
      t.integer :deck_list_id, null: false

      t.timestamps null: false
    end
    create_table :sideboard_ins do |t|
      t.integer :sideboard_plan_id, null: false
      t.integer :card_id, null: false
      t.integer :amount, null: false

      t.timestamps null: false
    end
    create_table :sideboard_outs do |t|
      t.integer :sideboard_plan_id, null: false
      t.integer :card_id, null: false
      t.integer :amount, null: false
      t.timestamps null: false
    end
  end
end
