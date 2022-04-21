class AddPushedToCardScriptSubmissions < ActiveRecord::Migration
  def change
    add_column :card_script_submissions, :pushed, :boolean, null: false, default: false
    CardScriptSubmission.update_all(pushed: true)
  end
end
