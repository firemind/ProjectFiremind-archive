class AddIndexForFormatCardAssignment < ActiveRecord::Migration
  def change
    add_index :format_card_assignments, [:card_id, :format_id], unique: true
  end
end
