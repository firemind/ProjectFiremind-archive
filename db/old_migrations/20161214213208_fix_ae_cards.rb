class FixAeCards < ActiveRecord::Migration[5.0]
  def change
    Card.where("name like ?", '%Æ%').each do |c|
      c.name = c.name.gsub(/Æ/,'Ae')
      c.save!
    end
  end
end
