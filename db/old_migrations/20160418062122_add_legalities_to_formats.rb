class AddLegalitiesToFormats < ActiveRecord::Migration
  def change
    add_column :formats, :legalities, :binary, limit: 64.kilobytes
  end
end
