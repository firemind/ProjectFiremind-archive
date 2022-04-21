class ChangeNrInSetToString < ActiveRecord::Migration
  def change
    change_column :card_prints, :nr_in_set, :string
  end
end
