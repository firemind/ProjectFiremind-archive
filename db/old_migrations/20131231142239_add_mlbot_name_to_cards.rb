class AddMlbotNameToCards < ActiveRecord::Migration
  def change
    add_column :cards, :mlbot_name, :string
  end
end
