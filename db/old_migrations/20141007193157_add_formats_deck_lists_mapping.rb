class AddFormatsDeckListsMapping < ActiveRecord::Migration
  def change
    create_table "deck_lists_formats", id: false, force: true do |t|
      t.integer "deck_list_id", null: false
      t.integer "format_id", null: false
    end

    add_index "deck_lists_formats", ["deck_list_id", "format_id"], name: "ix_deck_list_id_format_id", unique: true, using: :btree
    add_index "deck_lists_formats", ["format_id"], name: "ix_format_id", using: :btree

  end
end
