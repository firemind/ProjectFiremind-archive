require 'rails_helper'

describe "Format", :type => :model do
  it "binary legality verification works" do
    card_pool = Card.order("rand()").last(1000).to_a
    f = Format.create({
      name: "Testing Format",
      legalities: Card.full_binary(card_pool.map &:id)
    })
    deck = Deck.new({
      title: "Format Test Deck",
      format_id: f.id
    })
    deck.decklist= card_pool.sample(30).map{|c| "#{rand(3)+1} #{c.name}" }.join("\n")
    deck.save
    assert_equal 0, deck.deck_list.to_legalities_binary & ~f.legalities.to_i
  end
end
