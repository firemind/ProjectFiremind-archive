class AddAutoQueueToFormats < ActiveRecord::Migration[5.1]
  def change
    add_column :formats, :auto_queue, :boolean, null: false, default: false
  end
end
