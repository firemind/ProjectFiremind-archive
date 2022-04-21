class AddAssigneeIdToDuels < ActiveRecord::Migration
  def change
    add_column :duels, :assignee_id, :integer
  end
end
