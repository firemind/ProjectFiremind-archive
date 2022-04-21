class AddAddedInNextReleaseToCards < ActiveRecord::Migration
  def change
    add_column :cards, :added_in_next_release, :boolean, default: false, null: false
  end
end
