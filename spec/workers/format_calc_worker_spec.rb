require 'rails_helper'

describe "FormatCalcWorker" do
  describe "format calc worker performs correctly" do
    it "Adds deck to correct format" do
      user  = FactoryGirl.create :user
      deck1 = FactoryGirl.create :naya_deck, {author: user}
      FormatCalcWorker.new.process_dl(deck1.deck_list)
      expect(deck1.deck_list.formats).to include(Format.modern)
      expect(deck1.deck_list.formats).to_not include(Format.standard)

    end
  end
end
