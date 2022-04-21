require 'rails_helper'

describe "Archetypes" do
  describe "POST /archetypes/classify" do
    it "Classify modern deck correctly" do
      modern = FactoryGirl.create(:modern)

      post "/archetypes/classify", params:{
        deck: {
          format_id: modern.id,
          decklist: <<-DECK
4 Blighted Agent
2 Breeding Pool
4 Dismember
1 Distortion Strike
3 Dryad Arbor
2 Forest
4 Gitaxian Probe
4 Glistener Elf
4 Inkmoth Nexus
4 Might of Old Krosa
2 Misty Rainforest
4 Mutagenic Growth
4 Noble Hierarch
2 Pendelhaven
4 Rancor
1 Twisted Image
2 Verdant Catacombs
4 Vines of Vastwood
3 Windswept Heath
2 Wooded Foothills
DECK
        }
      }

      expect(assigns("at").name).to eq("Test Archetype")


    end
  end
end
