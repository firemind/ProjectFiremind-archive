FactoryGirl.define do
  factory :deck do
    title "Some Deck"
    format_id 1
    sequence(:author) do |i|
      FactoryGirl.create :user, name: "Deck Creator #{i}", email: "deck-creator-#{i}@firemind.ch"
    end
    avatar "avatar14.png"
    trait :naya do
      decklist <<-EOF
# 21 creatures
4 Avacyn's Pilgrim
4 Boros Reckoner
2 Ghor-Clan Rampager
4 Loxodon Smiter
3 Scavenging Ooze
4 Voice of Resurgence

# 16 spells
4 Advent of the Wurm
2 Ajani, Caller of the Pride
2 Mizzium Mortars
4 Oblivion Ring
4 Shock

# 23 lands
4 Clifftop Retreat
4 Rootbound Crag
4 Sacred Foundry
4 Stomping Ground
3 Sunpetal Grove
4 Temple Garden
      EOF
    end
    trait :gruul do
      decklist <<-EOF
# 30 creatures
4 Boros Reckoner
4 Flinthoof Boar
4 Ghor-Clan Rampager
4 Hellrider
2 Lightning Mauler
4 Rakdos Cackler
4 Strangleroot Geist
4 Stromkirk Noble

# 9 spells
3 Mizzium Mortars
3 Pillar of Flame
3 Searing Spear

# 21 lands
11 Mountain
4 Rootbound Crag
4 Stomping Ground
2 Temple Garden
      EOF
    end

    trait :delver do
      decklist <<-EOF
# 16 creatures
4 Delver of Secrets
4 Grim Lavamancer
4 Snapcaster Mage
4 Young Pyromancer

# 25 spells
1 Blood Moon
2 Burst Lightning
4 Lightning Bolt
3 Mana Leak
3 Pillar of Flame
3 Remand
1 Spell Pierce
2 Spell Snare
1 Sword of Fire and Ice
1 Twisted Image
4 Vapor Snag

# 19 lands
6 Island
1 Mountain
4 Scalding Tarn
3 Steam Vents
4 Sulfur Falls
1 Tectonic Edge
      EOF
    end
    factory :naya_deck,   traits: [:naya]
    factory :gruul_deck,   traits: [:gruul]
    factory :delver_deck,   traits: [:delver]
  end
end
