class AddColumnsToVersions < ActiveRecord::Migration
  def change
    add_column :versions, :revision, :integer
  end
end
