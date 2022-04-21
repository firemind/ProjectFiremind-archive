class SwitchToEnumForDuelsStatus < ActiveRecord::Migration
  def change
    rename_column :duels, :state, :state_old
    add_column :duels, :state, :integer, null: false, default: 0
    add_index "duels", :state
    Duel.where(state_old: :new).update_all(state: 0)
    Duel.where(state_old: :started).update_all(state: 1)
    Duel.where(state_old: :failed).update_all(state: 2)
    Duel.where(state_old: :finished).update_all(state: 3)
    remove_column :duels, :state_old
  end
end
