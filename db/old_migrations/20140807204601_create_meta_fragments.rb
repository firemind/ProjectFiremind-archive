class CreateMetaFragments < ActiveRecord::Migration
  def change
    create_table :meta_fragments do |t|
      t.integer :meta_id
      t.integer :deck_id
      t.integer :occurances

      t.timestamps
    end
  end
end
