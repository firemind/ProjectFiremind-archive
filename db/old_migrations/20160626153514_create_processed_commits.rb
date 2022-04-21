class CreateProcessedCommits < ActiveRecord::Migration
  def change
    create_table :processed_commits do |t|
      t.string :name, null: false

      t.timestamps null: false
    end
    ProcessedCommit.create(name: "839041b30876f4afb900aabebd9fe1fc0e6b1caf")
  end
end
