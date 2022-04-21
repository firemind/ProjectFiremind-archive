class AllowNullOnSysuserId < ActiveRecord::Migration
  def change
    change_column :ai_rating_matches, :sysuser_id, :integer, null: true
  end
end
