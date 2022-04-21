class MakeUniqueIndexForUdi < ActiveRecord::Migration
  def change
    remove_index "deck_lists", name: "ix_udi"
    add_index "deck_lists", ["udi"], name: "ix_udi", unique: true, using: :btree
  end
end
