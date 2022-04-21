class CreateRatings < ActiveRecord::Migration
  def change
    create_table :ratings do |t|
      t.integer :deck_id
      t.integer :format_id
      t.integer :deck_revision
      t.float :value

      t.timestamps
    end
  end
end
