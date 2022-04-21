class CreateCardScriptSubmissions < ActiveRecord::Migration
  def change
    create_table :card_script_submissions do |t|
      t.integer :card_id
      t.text :config
      t.text :script
      t.integer :user_id
      t.text :comment

      t.timestamps
    end
  end
end
