class CreateMisclassifications < ActiveRecord::Migration[5.0]
  def change
    create_table :misclassifications do |t|
      t.integer :expected_id, null: false
      t.integer :predicted_id, null: false

      t.timestamps
    end
    add_index :misclassifications, :expected_id
    add_index :misclassifications, :predicted_id
  end
end
