class AddThumbPrintIdToArchetypes < ActiveRecord::Migration[5.0]
  def change
    add_column :archetypes, :thumb_print_id, :integer
  end
end
