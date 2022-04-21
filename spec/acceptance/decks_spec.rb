require 'spec_helper'
require 'rspec_api_documentation/dsl'

resource "Api::V1::Decks" do
  api_header
  post "/api/v1/decks.json" do
    parameter :deck
    parameter :title, "Name under which the deck is visible to the user", scope: :deck
    parameter :description, "Optional description for the deck", scope: :deck
    parameter :decklist, "Decklist as text with each line starting with the number of cards followed by the card name. Lines starting with # and blank lines are ignored.", scope: :deck
    parameter :format_name, "Format in which the deck is listed for the user (Standard, Modern, Legacy, Vintage or Pauper)", scope: :deck

    let(:title) do
      "my test deck"
    end
    let(:description) do
      "some description of the deck"
    end
    let(:format_name) do
      "Modern"
    end
    let(:user) do
      user  = FactoryGirl.create :user
      user.generate_access_token!
      user
    end
    let(:decklist) do
      decklist = <<-TXT
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
TXT
    end
    let(:raw_post) { params.to_json }
    example "Create a deck" do
      header "Authorization", "Token token=#{user.access_token}"

      explanation "Note that the returned deck_list_id does not match the id. The reason for this is that deck_lists are not duplicated on the server and the deck is basically just a reference to the deck_list with a custom name, description and avatar. For creating duels use the deck_list_id."

      do_request

      expect(headers["Accept"]).to eq("application/json")
      expect(status).to eq(201)
      expect(user.decks.last.title).to eq("my test deck")
      expect(user.decks.last.deck_list.as_text.gsub("\r",'')).to eq(decklist)
    end
  end
end
