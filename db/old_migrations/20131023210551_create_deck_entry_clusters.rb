class CreateDeckEntryClusters < ActiveRecord::Migration
  def up
    create_table :deck_entry_clusters do |t|
      t.string :name
      t.references :deck

      t.timestamps
    end
    create_table :deck_entries_entry_clusters, :id => false do |t|
      t.references :deck_entry
      t.references :deck_entry_cluster
    end
    add_index :deck_entries_entry_clusters, [:deck_entry_id, :deck_entry_cluster_id], :name => 'ix_deck_entry_cluster_both_ids'
    add_index :deck_entries_entry_clusters, :deck_entry_cluster_id, :name => 'ix_deck_entry_cluster_cluster_id'
  end

  def down
    drop_table :deck_entry_clusters
    drop_table :deck_entries_deck_entry_clusters
    remove_index :ix_deck_entry_cluster_both_ids
    remove_index :ix_deck_entry_cluster_cluster_id
  end
end
