class AddColumnToCardScriptSubmission < ActiveRecord::Migration
  def change
    add_column :card_script_submissions, :token_name, :string
  end
end
