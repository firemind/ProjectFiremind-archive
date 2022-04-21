class CreateArchetypes < ActiveRecord::Migration
  def change
    create_table :archetypes, force: true do |t|
      t.string :name

      t.timestamps
    end
  end
end
