class CreateAiRatingMatches < ActiveRecord::Migration
  def change
    create_table :ai_rating_matches do |t|
      t.string :ai1_name, null: false
      t.string :ai1_identifier
      t.string :ai2_name, null: false
      t.string :ai2_identifier
      t.integer :ai_strength, null: false
      t.integer :owner_id, null: false
      t.string :git_repo
      t.string :git_branch
      t.string :git_commit_hash
      t.string :api_key, null: false

      t.timestamps
    end
  end
end
