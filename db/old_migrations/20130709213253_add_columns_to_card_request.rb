class AddColumnsToCardRequest < ActiveRecord::Migration
  def change
    add_column :card_requests, :state_comment, :text
  end
end
