class AddArchetypeBannerFields < ActiveRecord::Migration[5.0]
  def change
    add_column :archetypes, :has_banner, :boolean, null: false, default: false
    add_column :card_prints, :has_crop, :boolean, null: false, default: false
  end
end
