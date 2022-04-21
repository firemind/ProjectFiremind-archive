class CreateAiMistakes < ActiveRecord::Migration
  def change
    create_table :ai_mistakes do |t|
      t.integer :user_id
      t.integer :game_id
      t.text :decision
      t.text :correct_choice
      t.text :options_not_considered
      t.integer :log_line_number

      t.timestamps
    end
  end
end
