class AddCsmFlagToDuels < ActiveRecord::Migration
  def change
    add_column :duels, :card_script_submission_id, :integer
    remove_column :duels, :scriptcheck
  end
end
