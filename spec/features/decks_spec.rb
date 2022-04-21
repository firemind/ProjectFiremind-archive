require 'rails_helper'

describe "decks management", :type => :feature do
  it "creates a deck" do
    user  = FactoryGirl.create :user
    user.confirm
    login(user)
    format = Format.where(name: 'Modern').first


    visit '/decks/new'
    within("#new_deck") do
      fill_in 'Title', :with => "My New Deck"
      select "Modern", from: 'Format'
      fill_in 'Description', :with => "A description for this deck"
      fill_in 'Decklist', :with => <<-EOF
# 33 creatures
4 Birds of Paradise
2 Deceiver Exarch
1 Eternal Witness
1 Glen Elendra Archmage
2 Kiki-Jiki, Mirror Breaker
3 Kitchen Finks
1 Linvala, Keeper of Silence
1 Murderous Redcap
4 Noble Hierarch
1 Phantasmal Image
1 Qasali Pridemage
3 Restoration Angel
1 Scavenging Ooze
1 Spellskite
1 Sylvan Caryatid
1 Tarmogoyf
2 Voice of Resurgence
2 Wall of Omens
1 Zealous Conscripts

# 5 spells
4 Birthing Pod
1 Path to Exile

# 23 lands
4 Arid Mesa
1 Breeding Pool
2 Copperline Gorge
2 Forest
2 Gavony Township
1 Grove of the Burnwillows
3 Misty Rainforest
1 Plains
1 Razorverge Thicket
1 Sacred Foundry
1 Steam Vents
1 Stomping Ground
3 Temple Garden
      EOF
    end
    click_button 'Create Deck'
    expect(page).to have_content 'Deck was successfully created'
  end
  it "updates a deck" do
    user  = FactoryGirl.create :user
    user.confirm
    login(user)
    deck1 = FactoryGirl.create :naya_deck, {author: user}

    visit "/decks/#{deck1.id}/edit"
    within("#edit_deck_#{deck1.id}") do
      fill_in 'Title', :with => "My Changed Deck"
    end
    click_button 'Update Deck'
    expect(page).to have_content 'Deck was successfully updated'
    deck1.reload
    expect(deck1.title).to eq("My Changed Deck")
  end

end
