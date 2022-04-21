class MakeUdiUnique < ActiveRecord::Migration
  def change
    change_column :deck_lists, :udi, :string, limit: 40, unique: true
  end
end
