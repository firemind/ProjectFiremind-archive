class DeviseTokenAuthCreateUsers < ActiveRecord::Migration
  def change
    add_column :users,  :tokens, :text
    User.where(provider: nil).update_all(provider: "email")
    change_column :users, :provider, :string, null: false, default: 'email'
  end
end
