class AddWorkerQueueToUsers < ActiveRecord::Migration
  def change
    add_column :users, :worker_queue, :string, null: false, default: 'new'
    User.where(sysuser:true).update_all(worker_queue: 'sysnew')
  end
end
