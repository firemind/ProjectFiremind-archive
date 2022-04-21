class CleanUpDuplicateDecks < ActiveRecord::Migration[5.1]
  def change
    dls = DeckList.left_joins(:decks).select("deck_lists.*, count(decks.id) as deck_count").group("deck_lists.id").having("deck_count > 1")
    dls.each do |dl|
      del_count = dl.decks.where(author_id: 71).where.not(id: dl.decks.first.id).destroy_all
      puts del_count.inspect
    end
  end
end
