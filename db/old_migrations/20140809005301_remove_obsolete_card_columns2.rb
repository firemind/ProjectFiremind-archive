class RemoveObsoleteCardColumns2 < ActiveRecord::Migration
  def change
     remove_column :cards, :do_not_enable
     remove_column :cards, :temp_root_flag
     remove_column :cards, :image_file_name
     remove_column :cards, :image_content_type
     remove_column :cards, :image_file_size
     remove_column :cards, :image_updated_at
     remove_column :cards, :generated_mana
  end
end
