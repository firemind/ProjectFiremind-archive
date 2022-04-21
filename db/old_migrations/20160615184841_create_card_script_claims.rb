class CreateCardScriptClaims < ActiveRecord::Migration
  def change
    create_table :card_script_claims do |t|
      t.integer :card_id
      t.integer :user_id

      t.timestamps null: false
    end
  end
end
