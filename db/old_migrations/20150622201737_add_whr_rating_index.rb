class AddWhrRatingIndex < ActiveRecord::Migration
  def change
    add_index "ratings", ["whr_rating"], name: "ix_whr_rating", using: :btree
  end
end
