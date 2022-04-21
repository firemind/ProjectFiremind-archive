class AddFormatIdToArchetypes < ActiveRecord::Migration
  def change
    add_column :archetypes, :format_id, :integer, null: false
  end
end
