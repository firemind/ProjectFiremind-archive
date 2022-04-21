class CreateArchetypeAliases < ActiveRecord::Migration
  def change
    create_table :archetype_aliases do |t|
      t.string :name, null: false
      t.integer :archetype_id, null: false

      t.timestamps null: false
    end
    add_index "archetype_aliases", ["archetype_id", "name"], unique: true, using: :btree
    {
      'Naya Zoo' => 'Zoo',
      'Jeskai Black' => 'Dark Jeskai',
      'Red-Green Landfall' => 'R/G Landfall',
      'Splinter Twin' => 'Blue-Red Twin',
      'Bring to Light Control' => '5c Bring to Light',
      'Red Aggro' => 'Mono Red Aggro',
      'Mono-Green Aggro' => 'Mono Green Stompy',
      'RUG Delver' => 'Temur Delver',
      'Junk' => 'Abzan',
      'Death & Taxes' => 'Death and Taxes',
      'Mono-White Hatebears' => 'Death and Taxes',
      'UR Storm' => 'Storm',
      'Green Ramp' => 'Mono G Eldrazi',
      'WU Merfolk' => 'UW Merfolk',
      'Mono Red Aggro ' => 'Mono Red Burn',
      'Burn' => 'Mono Red Burn',
      'Jeskai Midrange' => 'Jeskai',
      'UWR Miracles' => 'Miracles',
      'Suicide Zoo' => 'Zoo-icide',
      'Jund Suicide Zoo' => 'Zoo-icide',
      'Painter' => 'Imperial Painter',
      'Oath of Druids' => 'Grisel Oath',
      'Sultai Delver' => 'BUG Delver',
      'BW Eldrazi' => 'B/W Eldrazi',
      'Azorius Control' => 'U/W Control',
      'UWR Delver' => 'Jeskai Delver',
      'W/B Eldrazi' => 'B/W Eldrazi',
      'Faeries' => 'Blue-Black Faeries',
      'UG 12-Post' => '12-Post',
      'C Eldrazi' => 'Colorless Eldrazi',
    }.each do |k,v|
      if at = Archetype.where(name: v).first
        aa = ArchetypeAlias.create(name: k, archetype_id: at.id)
      else
        puts "No archetype: #{v}"
      end
    end
    drop_table :archetype_staples
  end
end
