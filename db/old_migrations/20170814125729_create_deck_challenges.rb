class CreateDeckChallenges < ActiveRecord::Migration[5.1]
  def change
    create_table :deck_challenges do |t|
      t.integer :duel_queue_id, null: false
      t.integer :deck_list_id, null: false
      t.integer :user_id, null: false
      t.integer :format_id, null: false
      t.boolean :featured, null: false, default: false
      t.text :description
      t.integer :winner_id

      t.timestamps
    end

    create_table :challenge_entries do |t|
      t.integer :user_id, null: false
      t.integer :deck_list_id, null: false
      t.integer :deck_challenge_id, null: false
      t.timestamps
    end

    add_column :duels, :challenge_entry_id, :integer

    add_index :deck_challenges, [:featured,:winner_id]
    add_index :deck_challenges, :winner_id
    add_index :challenge_entries, :deck_challenge_id
    add_index :challenge_entries, [:deck_challenge_id, :user_id], unique: true
    add_index :duels, :challenge_entry_id
  end
end
