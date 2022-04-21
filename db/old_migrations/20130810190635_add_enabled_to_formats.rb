class AddEnabledToFormats < ActiveRecord::Migration
  def change
    add_column :formats, :enabled, :boolean, null: false, default: true
  end
end
