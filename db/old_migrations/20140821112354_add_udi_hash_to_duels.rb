class AddUdiHashToDuels < ActiveRecord::Migration
  def change
    add_column :duels, :deck1_udi_hash, :string, limit: 32
    add_column :duels, :deck2_udi_hash, :string, limit: 32
    add_index :duels, :deck1_udi_hash, name: 'ix_deck1_udi_hash', length: 10
    add_index :duels, :deck2_udi_hash, name: 'ix_deck2_udi_hash', length: 10
  end
end
