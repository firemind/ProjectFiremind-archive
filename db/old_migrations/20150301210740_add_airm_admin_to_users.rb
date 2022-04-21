class AddAirmAdminToUsers < ActiveRecord::Migration
  def change
    add_column :users, :airm_admin, :boolean, null: false, default: false
  end
end
