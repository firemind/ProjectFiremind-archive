class AddDescriptionToFormats < ActiveRecord::Migration
  def change
    add_column :formats, :description, :text
  end
end
