class CreateFormatCalcLogs < ActiveRecord::Migration[5.0]
  def change
    create_table :format_calc_logs do |t|
      t.integer :deck_list_id, null: false
      t.string :formats, null: false

      t.timestamps
    end
  end
end
