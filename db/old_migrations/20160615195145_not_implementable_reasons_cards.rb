class NotImplementableReasonsCards < ActiveRecord::Migration
  def change
    create_table :cards_not_implementable_reasons do |t|
      t.integer :card_id, null: false
      t.integer :not_implementable_reason_id, null: false
    end
  end
end
