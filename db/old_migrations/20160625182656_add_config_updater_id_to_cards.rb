class AddConfigUpdaterIdToCards < ActiveRecord::Migration
  def change
    add_column :cards, :config_updater_id, :integer
  end
end
