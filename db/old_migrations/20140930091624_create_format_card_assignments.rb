class CreateFormatCardAssignments < ActiveRecord::Migration
  def change
    create_table :format_card_assignments do |t|
      t.integer :format_id, null: false
      t.integer :card_id, null: false
      t.integer :limit, limit: 2

      t.timestamps
    end
  end
end
