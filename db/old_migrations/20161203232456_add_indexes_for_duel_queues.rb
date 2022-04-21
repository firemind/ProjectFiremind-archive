class AddIndexesForDuelQueues < ActiveRecord::Migration[5.0]
  def change
    add_index :duels, [:duel_queue_id]
    add_index :duel_queues, [:ai1]
    add_index :duel_queues, [:ai2]
  end
end
