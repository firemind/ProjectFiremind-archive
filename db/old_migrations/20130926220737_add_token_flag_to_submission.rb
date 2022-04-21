class AddTokenFlagToSubmission < ActiveRecord::Migration
  def change
    add_column :card_script_submissions, :is_token, :boolean, null: false, default: false
  end
end
