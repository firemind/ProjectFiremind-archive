class AddMayAddUnimplementableReasonsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :may_add_unimplementable_reasons, :boolean
  end
end
