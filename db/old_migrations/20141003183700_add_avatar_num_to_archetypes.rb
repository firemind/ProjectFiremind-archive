class AddAvatarNumToArchetypes < ActiveRecord::Migration
  def change
    add_column :archetypes, :avatar_num, :integer, null: false, default: 1, limit: 1
  end
end
