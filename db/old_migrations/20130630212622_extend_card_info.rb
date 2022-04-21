class ExtendCardInfo < ActiveRecord::Migration
  def change
    add_column :cards, :magarena_script, :string
    add_column :cards, :enabled, :boolean, default: false, null: false
  end
end
