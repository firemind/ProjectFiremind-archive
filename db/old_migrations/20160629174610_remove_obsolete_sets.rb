class RemoveObsoleteSets < ActiveRecord::Migration
  def change
    Card.__elasticsearch__.create_index!
    Card.import
    ['PP2', 'PCP', 'UNH', 'UGL'].each do |short|
      ed = Edition.where(short: short).first
      ed.card_prints.each do |cp|
        if cp.card.card_prints.size == 1
          cp.card.destroy
        end
        cp.destroy
      end
      ed.destroy
    end
  end
end
