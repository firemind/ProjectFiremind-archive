class AddRequeueCountToDuels < ActiveRecord::Migration
  def change
    add_column :duels, :requeue_count, :integer, null: false, default: 0
  end
end
