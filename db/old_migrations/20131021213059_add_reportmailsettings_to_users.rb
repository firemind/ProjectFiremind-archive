class AddReportmailsettingsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :receive_weekly_report, :boolean, default: true, null: false
  end
end
