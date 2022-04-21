class AddColumnToDuels < ActiveRecord::Migration
  def change
    add_column :duels, :format_id, :integer
  end
end
