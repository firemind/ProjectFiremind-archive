class CreateFormats < ActiveRecord::Migration
  def change
    create_table :formats do |t|
      t.string :name, null: false, unqiue: true

      t.timestamps
    end
  end
end
