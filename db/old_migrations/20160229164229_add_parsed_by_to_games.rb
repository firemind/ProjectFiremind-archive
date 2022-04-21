class AddParsedByToGames < ActiveRecord::Migration
  def change
    add_column :games, :parsed_by, :integer
  end
end
