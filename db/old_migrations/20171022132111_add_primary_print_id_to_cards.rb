class AddPrimaryPrintIdToCards < ActiveRecord::Migration[5.1]
  def change
    add_column :cards, :primary_print_id, :integer
    add_index :cards, :primary_print_id
    Card.all.find_each do |c|
      c.primary_print = c.card_prints.where(with_image: true).order("img_sort desc,created_at desc").first
      c.save!
    end
    remove_column :card_prints, :img_sort
  end
end
