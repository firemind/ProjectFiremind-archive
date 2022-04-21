class AddWorkerQueueToDuels < ActiveRecord::Migration
  def change
    add_column :duels, :worker_queue, :string, null: false, default: 'new'
  end
end
