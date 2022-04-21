class AddTimeTakenToMulliganChoices < ActiveRecord::Migration
  def change
    add_column :mulligan_decisions, :time_taken, :integer
  end
end
