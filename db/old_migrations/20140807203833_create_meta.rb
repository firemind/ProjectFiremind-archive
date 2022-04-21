class CreateMeta < ActiveRecord::Migration
  def change
    create_table :meta do |t|
      t.string :name
      t.integer :format_id
      t.integer :user_id

      t.timestamps
    end
  end
end
