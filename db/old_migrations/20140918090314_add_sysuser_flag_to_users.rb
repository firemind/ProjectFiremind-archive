class AddSysuserFlagToUsers < ActiveRecord::Migration
  def change
    add_column :users, :sysuser, :boolean, null: false, default: false
  end
end
