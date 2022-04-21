class AddMissingIndexes < ActiveRecord::Migration
  def change
    add_index :meta, :format_id
    add_index :meta, :user_id
    add_index :tournament_results, :tournament_id
    add_index :deck_lists_formats, :deck_list_id
    add_index :tournaments, :format_id
    add_index :archetypes, :format_id
    add_index :card_prints, :edition_id
    add_index :card_prints, :card_id
    add_index :duels, :user_id
    add_index :duels, :assignee_id
    add_index :duels, :format_id
    add_index :duels, :card_script_submission_id
    add_index :decks, :format_id
    add_index :decks, :author_id
    add_index :decks, :forked_from_id
    add_index :decks, :tournament_result_id
    add_index :decks, :deck_list_id
    add_index :restricted_cards, :card_id
    add_index :restricted_cards, :format_id
    add_index :rulings, :card_id
    add_index :ratings, :format_id
    add_index :price_changes, :card_print_id
    add_index :playable_hand_entries, :deck_id
    add_index :playable_hand_entries, :deck_entry_cluster_id
    add_index :meta_fragments, :meta_id
    add_index :meta_fragments, :archetype_id
    add_index :ai_mistakes, :game_id
    add_index :ai_mistakes, :user_id
    add_index :deck_lists, :archetype_id
    add_index :card_requests, :card_id
    add_index :card_requests, :user_id
    add_index :card_script_submissions, :card_id
    add_index :card_script_submissions, :user_id
    add_index :deck_entry_clusters, :deck_id
    add_index :deck_entries, :card_id
  end
end
