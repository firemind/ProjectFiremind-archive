class AddDefaultForPublicOnDuels < ActiveRecord::Migration
  def change
    change_column :duels, :public, :boolean, null: false, default: true
  end
end
