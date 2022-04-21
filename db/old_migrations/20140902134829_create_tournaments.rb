class CreateTournaments < ActiveRecord::Migration
  def change
    create_table :tournaments do |t|
      t.integer :format_id
      t.string :type
      t.integer :nr

      t.timestamps
    end
  end
end
