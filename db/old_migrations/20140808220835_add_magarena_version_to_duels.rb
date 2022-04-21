class AddMagarenaVersionToDuels < ActiveRecord::Migration
  def change
    add_column :duels, :magarena_version_major, :integer
    add_column :duels, :magarena_version_minor, :integer
  end
end
