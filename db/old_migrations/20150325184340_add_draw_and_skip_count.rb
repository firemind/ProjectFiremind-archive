class AddDrawAndSkipCount < ActiveRecord::Migration
  def change
    add_column :mulligan_decisions, :draw, :boolean, null: false, default: false
    add_column :dealt_hands, :skip_count, :integer, null: false, default: 0
  end
end
