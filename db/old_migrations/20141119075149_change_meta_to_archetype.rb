class ChangeMetaToArchetype < ActiveRecord::Migration
  def change
    MetaFragment.delete_all
    remove_column :meta_fragments, :deck_id
    add_column :meta_fragments, :archetype_id, :integer, null: false
  end
end
