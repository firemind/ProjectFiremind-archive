class ActsAsVotableMigration < ActiveRecord::Migration[5.1]
  def self.up
    create_table :votes do |t|

      t.references :votable, :polymorphic => true
      t.references :voter, :polymorphic => true

      t.boolean :vote_flag
      t.string :vote_scope
      t.integer :vote_weight

      t.timestamps
    end

    add_column :card_requests, :cached_votes_total, :integer, :default => 0
    add_column :card_requests, :cached_votes_score, :integer, :default => 0
    add_column :card_requests, :cached_votes_up, :integer, :default => 0
    add_column :card_requests, :cached_votes_down, :integer, :default => 0
    add_column :card_requests, :cached_weighted_score, :integer, :default => 0
    add_column :card_requests, :cached_weighted_total, :integer, :default => 0
    add_column :card_requests, :cached_weighted_average, :float, :default => 0.0
    add_index  :card_requests, :cached_votes_total
    add_index  :card_requests, :cached_votes_score
    add_index  :card_requests, :cached_votes_up
    add_index  :card_requests, :cached_votes_down
    add_index  :card_requests, :cached_weighted_score
    add_index  :card_requests, :cached_weighted_total
    add_index  :card_requests, :cached_weighted_average

    if ActiveRecord::VERSION::MAJOR < 4
      add_index :votes, [:votable_id, :votable_type]
      add_index :votes, [:voter_id, :voter_type]
    end

    add_index :votes, [:voter_id, :voter_type, :vote_scope]
    add_index :votes, [:votable_id, :votable_type, :vote_scope]

    sql = "SELECT source_id, target_id, value, created_at, updated_at from rs_evaluations;"
    result = ActiveRecord::Base.connection.execute(sql)
    result.to_a.each do |res|
      if res[0] && res[1]
        sql = "insert into votes (votable_type, votable_id, voter_type, voter_id, vote_weight, vote_flag, created_at, updated_at) values('CardRequest', #{res[1]}, 'User', #{res[0]}, 1, true, '#{res[3].to_s(:db)}', '#{res[4].to_s(:db)}');"
        result = ActiveRecord::Base.connection.execute(sql)
      end
    end
    CardRequest.find_each(&:update_cached_votes)
    drop_table :rs_evaluations
    drop_table :rs_reputation_messages
    drop_table :rs_reputations
  end

  def self.down
    drop_table :votes
    remove_column :card_requests, :cached_votes_total
    remove_column :card_requests, :cached_votes_score
    remove_column :card_requests, :cached_votes_up
    remove_column :card_requests, :cached_votes_down
    remove_column :card_requests, :cached_weighted_score
    remove_column :card_requests, :cached_weighted_total
    remove_column :card_requests, :cached_weighted_average
  end
end
