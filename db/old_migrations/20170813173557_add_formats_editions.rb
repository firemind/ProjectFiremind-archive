class AddFormatsEditions < ActiveRecord::Migration[5.1]
  def change
    create_table "editions_formats", id: false, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
      t.integer "edition_id", null: false
      t.integer "format_id",    null: false
      t.index ["edition_id", "format_id"], name: "ix_edition_id_format_id", unique: true, using: :btree
      t.index ["edition_id"], name: "index_editionss_formats_on_edition_id", using: :btree
      t.index ["format_id"], name: "ix_format_id", using: :btree
    end
    return if Rails.env.test?
    standard = Format.standard
    standard.editions= Edition.where(standard_legal: true)
    standard.save!
   
    modern = Format.modern
    modern.editions= Edition.where(modern_legal: true)
    modern.save!

    legacy = Format.legacy
    legacy.editions= Edition.all
    legacy.save!

    vintage = Format.vintage
    vintage.editions= Edition.all
    vintage.save!

    pauper = Format.pauper
    pauper.editions= Edition.all
    pauper.save!
   
    Format.where(enabled: false).each do |f|
      p f.name
      if f.format_type == "standard"
        f.editions = Edition.where(short: f.name.split(' ')[1].split('-'))
      elsif f.format_type == "modern"
        f.editions = Edition.where("id <= ?", Edition.where(short: f.name.split(' ')[1]).first.id).where(modern_legal: true)
      elsif f.format_type.nil?
        next
      else
        f.editions = Edition.where("id <= ?", Edition.where(short: f.name.split(' ')[1]).first.id)
      end
      f.save!
    end
  end
end
