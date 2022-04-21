class MainController < ApplicationController
  def home
    #@latest_duels = if current_user
      #my_deck_ids = current_user.decks.select("deck_list_id").collect(&:deck_list_id)
      #following_user_deck_ids = current_user.following_by_type("User").inject([]){|all, u| all | u.decks.select("deck_list_id").collect(&:deck_list_id)}
      #following_deck_ids = current_user.following_by_type("Deck").collect(&:deck_list_id)
      #ids = my_deck_ids | following_user_deck_ids | following_deck_ids
      #Duel.finished.where("deck_list1_id in (?) or deck_list2_id in (?)", ids , ids).
        #order("created_at desc").limit(10).
        #includes([{deck_list1: :archetype}, {deck_list2: :archetype}])
    #else
      #Duel.is_public.where(state: [:started,:finished]).order("created_at desc").limit(5).
        #includes([:format, {deck_list1: :archetype}, {deck_list2: :archetype}])
    #end
    @featured_challenge = DeckChallenge.unfinished.where(featured: true).first
    @duel_queue = DuelQueue.default
  end

  def about
  end

  def status
    @card_requests = CardRequest.order("cached_votes_total desc").includes(:card)
    @failed_duels = Duel.failed.includes(deck_list1: :archetype, deck_list2: :archetype, format: []).order("created_at desc").first(100)
    @card_script_submissions = CardScriptSubmission.order("created_at desc").includes(:card, :user, :duels)
  end

end
