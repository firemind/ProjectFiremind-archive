class AddDefaultToDuelState < ActiveRecord::Migration
  def change
    change_column :duels, :state, :string, null: false, default: 'new'
  end
end
