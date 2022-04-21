class AddSyncedAtToEditions < ActiveRecord::Migration[5.1]
  def change
    add_column :editions, :synced_at, :datetime
  end
end
