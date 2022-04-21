class FlipLegalities < ActiveRecord::Migration[5.0]
  def change
    Format.where("legalities < 0").each do|f|
      f.legalities = ~f.legalities.to_i
      f.save!
    end

  end
end
