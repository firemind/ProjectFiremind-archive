class UniquenessOfDuelQueueNameScopedToUserAndActive < ActiveRecord::Migration[5.0]
  def change
    remove_index :duel_queues, name: "index_duel_queues_on_name"
    add_index :duel_queues, ["name", "user_id", "active"], unique: true
  end
end
