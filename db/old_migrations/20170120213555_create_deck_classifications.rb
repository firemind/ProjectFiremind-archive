class CreateDeckClassifications < ActiveRecord::Migration[5.0]
  def change
    create_table :deck_classifications do |t|
      t.integer :deck_list_id
      t.string :source_ip
      t.integer :format_id

      t.timestamps
    end
  end
end
