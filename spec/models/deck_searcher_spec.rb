require 'rails_helper'

describe "DeckSearcher", :type => :model do
  before(:each) do
    @modern = Format.modern
    @legacy = Format.legacy
    @delver_archetype = FactoryGirl.create :archetype, format: @modern, name: "Blue-Red Delver"
    @ur_control_archetype = FactoryGirl.create :archetype, format: @modern, name: "Blue-Red Control"
    @delver_archetype_legacy = FactoryGirl.create :archetype, format: @legacy, name: "Blue-Red Delver"
    @delver_deck = FactoryGirl.create :delver_deck, title: "My Blue Aggro", format: @modern
    @delver_deck.deck_list.make_legal_in(@modern)
    @delver_deck.deck_list.archetype = @delver_archetype
    @delver_deck.deck_list.save!
    @gruul_archetype = FactoryGirl.create :archetype, format: @modern, name: "Green-Red Aggro"
    @gruul_deck = FactoryGirl.create :gruul_deck, title: "My Gruul Aggro", format: @modern
    @gruul_deck.deck_list.make_legal_in(@modern)
    @gruul_deck.deck_list.archetype = @gruul_archetype
    @gruul_deck.deck_list.save!
  end
  it "I can search by simple strings" do
    input = "My Blue Aggro"
    searcher = DeckSearcher.new(input)
    decks = searcher.query
    expect(searcher.errors).to be_empty
    expect(decks).to include(@delver_deck)
    expect(decks).to_not include(@gruul_deck)
  end
  it "I can search by card" do
    input = "card:Delver_of_Secrets"
    searcher = DeckSearcher.new(input)
    decks = searcher.query
    expect(searcher.errors).to be_empty
    expect(decks).to include(@delver_deck)
    expect(decks).to_not include(@gruul_deck)
  end
  it "I can search by multiple cards" do
    input = "card:Mountain card:Ghor-Clan_Rampager"
    searcher = DeckSearcher.new(input)
    decks = searcher.query
    expect(searcher.errors).to be_empty
    expect(decks).to_not include(@delver_deck)
    expect(decks).to include(@gruul_deck)
  end
  it "I can search by format" do
    input = "format:Modern"
    searcher = DeckSearcher.new(input)
    decks = searcher.query
    expect(searcher.errors).to be_empty
    expect(decks).to include(@delver_deck)
    expect(decks).to include(@gruul_deck)
  end
  it "I can search by partial archetype" do
    input = "Blue-Red"
    searcher = DeckSearcher.new(input)
    decks = searcher.query
    expect(decks).to be_empty
    expect(searcher.ambig_archetypes).to include(@delver_archetype)
    expect(searcher.ambig_archetypes).to include(@delver_archetype_legacy)
  end
  it "I can search by specific archetype" do
    input = "archetype:Blue-Red_Delver"
    searcher = DeckSearcher.new(input)
    decks = searcher.query
    expect(decks).to be_empty
    expect(searcher.ambig_archetypes).to include(@delver_archetype)
    expect(searcher.ambig_archetypes).to include(@delver_archetype_legacy)

    input = "archetype:Green-Red_Aggro"
    searcher = DeckSearcher.new(input)
    decks = searcher.query
    expect(searcher.errors).to be_empty
    expect(decks).to_not include(@delver_deck)
    expect(decks).to include(@gruul_deck)
  end
  it "I can search by partial archetype and format" do
    input = "Blue-Red Delver format:Modern"
    searcher = DeckSearcher.new(input)
    decks = searcher.query
    expect(searcher.errors).to be_empty
    expect(decks).to include(@delver_deck)
    expect(decks).to_not include(@gruul_deck)
  end
end
