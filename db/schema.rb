# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20181212181928) do

  create_table "active_admin_comments", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string "namespace"
    t.text "body", limit: 16777215
    t.string "resource_id", null: false
    t.string "resource_type", null: false
    t.integer "author_id"
    t.string "author_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["author_type", "author_id"], name: "index_active_admin_comments_on_author_type_and_author_id"
    t.index ["namespace"], name: "index_active_admin_comments_on_namespace"
    t.index ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource_type_and_resource_id"
  end

  create_table "admins", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["email"], name: "index_admins_on_email", unique: true
    t.index ["reset_password_token"], name: "index_admins_on_reset_password_token", unique: true
  end

  create_table "ai_mistakes", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer "user_id"
    t.integer "game_id"
    t.text "decision", limit: 16777215
    t.text "correct_choice", limit: 16777215
    t.text "options_not_considered", limit: 16777215
    t.integer "log_line_number"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["game_id"], name: "index_ai_mistakes_on_game_id"
    t.index ["user_id"], name: "index_ai_mistakes_on_user_id"
  end

  create_table "ai_rating_matches", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string "ai1_name", null: false
    t.string "ai1_identifier"
    t.string "ai2_name", null: false
    t.string "ai2_identifier"
    t.integer "ai_strength", null: false
    t.integer "owner_id", null: false
    t.string "git_repo"
    t.string "git_branch"
    t.string "git_commit_hash"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "sysuser_id"
    t.integer "iterations", default: 1, null: false
    t.integer "duel_queue_id", null: false
  end

  create_table "airm_decks", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer "deck_list1_id", null: false
    t.integer "deck_list2_id", null: false
    t.integer "rounds", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "archetype_aliases", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string "name", null: false
    t.integer "archetype_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["archetype_id", "name"], name: "index_archetype_aliases_on_archetype_id_and_name", unique: true
    t.index ["name"], name: "index_archetype_aliases_on_name", type: :fulltext
  end

  create_table "archetypes", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "format_id", null: false
    t.integer "avatar_num", limit: 1, default: 1, null: false
    t.boolean "has_banner", default: false, null: false
    t.integer "thumb_print_id"
    t.index ["format_id"], name: "index_archetypes_on_format_id"
    t.index ["name"], name: "index_archetypes_on_name", type: :fulltext
  end

  create_table "card_prints", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer "card_id"
    t.integer "edition_id"
    t.string "rarity"
    t.text "flavor_text", limit: 16777215
    t.string "artist"
    t.string "variation"
    t.float "price_low", limit: 24
    t.float "price_mid", limit: 24
    t.float "price_high", limit: 24
    t.float "mtgo_price_low", limit: 24
    t.float "mtgo_price_avg", limit: 24
    t.float "mtgo_price_med", limit: 24
    t.float "mtgo_price_high", limit: 24
    t.integer "mtgo_id"
    t.float "mtgo_buying_override", limit: 24
    t.float "mtgo_selling_override", limit: 24
    t.string "mlbot_name"
    t.integer "mtgo_buying_quantity"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "with_image", default: false, null: false
    t.string "nr_in_set"
    t.integer "multiverse_id"
    t.boolean "track_prices", default: false, null: false
    t.integer "mlbot_inventory"
    t.float "mlbot_sell_price", limit: 24
    t.boolean "has_crop", default: false, null: false
    t.boolean "has_thumb", default: false, null: false
    t.index ["card_id"], name: "index_card_prints_on_card_id"
    t.index ["edition_id"], name: "index_card_prints_on_edition_id"
  end

  create_table "card_requests", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer "user_id"
    t.integer "card_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text "state_comment", limit: 16777215
    t.integer "cached_votes_total", default: 0
    t.integer "cached_votes_score", default: 0
    t.integer "cached_votes_up", default: 0
    t.integer "cached_votes_down", default: 0
    t.integer "cached_weighted_score", default: 0
    t.integer "cached_weighted_total", default: 0
    t.float "cached_weighted_average", limit: 24, default: 0.0
    t.index ["cached_votes_down"], name: "index_card_requests_on_cached_votes_down"
    t.index ["cached_votes_score"], name: "index_card_requests_on_cached_votes_score"
    t.index ["cached_votes_total"], name: "index_card_requests_on_cached_votes_total"
    t.index ["cached_votes_up"], name: "index_card_requests_on_cached_votes_up"
    t.index ["cached_weighted_average"], name: "index_card_requests_on_cached_weighted_average"
    t.index ["cached_weighted_score"], name: "index_card_requests_on_cached_weighted_score"
    t.index ["cached_weighted_total"], name: "index_card_requests_on_cached_weighted_total"
    t.index ["card_id"], name: "index_card_requests_on_card_id"
    t.index ["user_id"], name: "index_card_requests_on_user_id"
  end

  create_table "card_script_claims", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.integer "card_id"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "card_script_submissions", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer "card_id"
    t.text "config", limit: 16777215
    t.text "script", limit: 16777215
    t.integer "user_id"
    t.text "comment", limit: 16777215
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "is_token", default: false, null: false
    t.string "token_name"
    t.boolean "pushed", default: false, null: false
    t.index ["card_id"], name: "index_card_script_submissions_on_card_id"
    t.index ["user_id"], name: "index_card_script_submissions_on_user_id"
  end

  create_table "card_translations", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer "card_id"
    t.string "locale"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["card_id"], name: "index_card_translations_on_card_id"
    t.index ["locale"], name: "index_card_translations_on_locale"
  end

  create_table "cards", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string "name"
    t.string "card_type"
    t.string "mana_cost"
    t.integer "cmc"
    t.string "power"
    t.string "toughness"
    t.string "creature_types"
    t.text "ability", limit: 16777215
    t.float "rating", limit: 24
    t.string "color"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "loyalty"
    t.integer "back_id"
    t.integer "number_int"
    t.string "magarena_script"
    t.boolean "enabled", default: false, null: false
    t.integer "mtgo_id"
    t.string "flip_name"
    t.integer "config_updater_id"
    t.boolean "added_in_next_release", default: false, null: false
    t.boolean "needs_groovy", default: false, null: false
    t.float "magarena_rating", limit: 24
    t.integer "primary_print_id"
    t.index ["name", "ability"], name: "index_cards_on_name_and_ability", type: :fulltext
    t.index ["name"], name: "index_cards_on_name", type: :fulltext
    t.index ["primary_print_id"], name: "index_cards_on_primary_print_id"
  end

  create_table "cards_keywords", id: false, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci" do |t|
    t.bigint "card_id"
    t.bigint "keyword_id"
    t.index ["card_id", "keyword_id"], name: "index_cards_keywords_on_card_id_and_keyword_id", unique: true
    t.index ["card_id"], name: "index_cards_keywords_on_card_id"
    t.index ["keyword_id"], name: "index_cards_keywords_on_keyword_id"
  end

  create_table "cards_not_implementable_reasons", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.integer "card_id", null: false
    t.integer "not_implementable_reason_id", null: false
  end

  create_table "challenge_entries", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.integer "user_id", null: false
    t.integer "deck_list_id", null: false
    t.integer "deck_challenge_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["deck_challenge_id", "user_id"], name: "index_challenge_entries_on_deck_challenge_id_and_user_id", unique: true
    t.index ["deck_challenge_id"], name: "index_challenge_entries_on_deck_challenge_id"
  end

  create_table "dealt_cards", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer "card_id", null: false
    t.integer "dealt_hand_id", null: false
    t.datetime "created_at", null: false
    t.index ["dealt_hand_id"], name: "index_dealt_cards_on_dealt_hand_id"
  end

  create_table "dealt_hands", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer "deck_list_id", null: false
    t.datetime "created_at", null: false
    t.integer "skip_count", default: 0, null: false
    t.index ["deck_list_id"], name: "index_dealt_hands_on_deck_list_id"
  end

  create_table "deck_challenges", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.integer "duel_queue_id", null: false
    t.integer "deck_list_id", null: false
    t.integer "user_id", null: false
    t.integer "format_id", null: false
    t.boolean "featured", default: false, null: false
    t.text "description"
    t.integer "winner_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["featured", "winner_id"], name: "index_deck_challenges_on_featured_and_winner_id"
    t.index ["winner_id"], name: "index_deck_challenges_on_winner_id"
  end

  create_table "deck_classifications", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.integer "deck_list_id"
    t.string "source_ip"
    t.integer "format_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "deck_entries", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer "card_id"
    t.integer "amount"
    t.string "group_type"
    t.integer "deck_list_id"
    t.index ["card_id", "amount"], name: "index_deck_entries_on_card_id_and_amount"
    t.index ["card_id", "deck_list_id"], name: "index_deck_entries_on_card_id_and_deck_list_id", unique: true
    t.index ["card_id"], name: "index_deck_entries_on_card_id"
    t.index ["deck_list_id"], name: "ix_deck_list_id"
  end

  create_table "deck_entries_entry_clusters", id: false, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer "deck_entry_id"
    t.integer "deck_entry_cluster_id"
    t.index ["deck_entry_cluster_id"], name: "ix_deck_entry_cluster_cluster_id"
    t.index ["deck_entry_id", "deck_entry_cluster_id"], name: "ix_deck_entry_cluster_both_ids"
  end

  create_table "deck_entry_clusters", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string "name"
    t.integer "deck_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["deck_id"], name: "index_deck_entry_clusters_on_deck_id"
  end

  create_table "deck_lists", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string "udi", limit: 40
    t.integer "archetype_id"
    t.string "colors"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "human_archetype_id"
    t.float "archetype_score", limit: 24, default: 0.0, null: false
    t.boolean "human_archetype_confirmed", default: false
    t.boolean "enabled", default: false, null: false
    t.integer "won_games_count", default: 0, null: false
    t.integer "lost_games_count", default: 0, null: false
    t.index ["archetype_id"], name: "index_deck_lists_on_archetype_id"
    t.index ["human_archetype_id"], name: "index_deck_lists_on_human_archetype_id"
    t.index ["udi"], name: "ix_udi", unique: true
  end

  create_table "deck_lists_formats", id: false, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer "deck_list_id", null: false
    t.integer "format_id", null: false
    t.index ["deck_list_id", "format_id"], name: "ix_deck_list_id_format_id", unique: true
    t.index ["deck_list_id"], name: "index_deck_lists_formats_on_deck_list_id"
    t.index ["format_id"], name: "ix_format_id"
  end

  create_table "decks", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string "title"
    t.text "description", limit: 16777215
    t.integer "author_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "public", default: true
    t.integer "forked_from_id"
    t.string "avatar", default: "avatar06.png", null: false
    t.boolean "track_prices", default: false, null: false
    t.integer "format_id"
    t.boolean "auto_generated", default: false, null: false
    t.integer "tournament_result_id"
    t.integer "deck_list_id", null: false
    t.integer "thumb_print_id"
    t.index ["author_id"], name: "index_decks_on_author_id"
    t.index ["deck_list_id"], name: "index_decks_on_deck_list_id"
    t.index ["forked_from_id"], name: "index_decks_on_forked_from_id"
    t.index ["format_id"], name: "index_decks_on_format_id"
    t.index ["title"], name: "index_decks_on_title", type: :fulltext
    t.index ["tournament_result_id"], name: "index_decks_on_tournament_result_id"
  end

  create_table "dismissed_decks", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string "deck_key", null: false
    t.integer "whr_rating", null: false
    t.integer "whr_uncertainty", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "duel_queues", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string "name", null: false
    t.string "access_token"
    t.string "ai1", null: false
    t.string "ai2", null: false
    t.integer "ai1_strength", null: false
    t.integer "ai2_strength", null: false
    t.integer "magarena_version_major", null: false
    t.integer "magarena_version_minor", null: false
    t.integer "life", null: false
    t.integer "user_id"
    t.boolean "active"
    t.text "custom_params"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["access_token"], name: "index_duel_queues_on_access_token", unique: true
    t.index ["ai1"], name: "index_duel_queues_on_ai1"
    t.index ["ai2"], name: "index_duel_queues_on_ai2"
    t.index ["name", "user_id", "active"], name: "index_duel_queues_on_name_and_user_id_and_active", unique: true
  end

  create_table "duels", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer "games_to_play", null: false
    t.integer "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "public", default: true, null: false
    t.integer "format_id"
    t.text "failure_message", limit: 16777215
    t.boolean "error_acknowledged", default: false
    t.integer "magarena_version_major"
    t.integer "magarena_version_minor"
    t.integer "assignee_id"
    t.integer "requeue_count", default: 0, null: false
    t.integer "card_script_submission_id"
    t.integer "deck_list1_id"
    t.integer "deck_list2_id"
    t.boolean "freeform", default: false, null: false
    t.integer "starting_seed"
    t.integer "state", default: 0, null: false
    t.integer "duel_queue_id", null: false
    t.integer "challenge_entry_id"
    t.index ["assignee_id"], name: "index_duels_on_assignee_id"
    t.index ["card_script_submission_id"], name: "index_duels_on_card_script_submission_id"
    t.index ["challenge_entry_id"], name: "index_duels_on_challenge_entry_id"
    t.index ["deck_list1_id"], name: "ix_deck_list1_id"
    t.index ["deck_list2_id"], name: "ix_deck_list2_id"
    t.index ["duel_queue_id"], name: "index_duels_on_duel_queue_id"
    t.index ["format_id", "state"], name: "index_duels_on_format_id_and_state"
    t.index ["format_id"], name: "index_duels_on_format_id"
    t.index ["state"], name: "index_duels_on_state"
    t.index ["user_id"], name: "index_duels_on_user_id"
  end

  create_table "editions", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string "name"
    t.string "short"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "mtgo", default: true, null: false
    t.date "release_date"
    t.datetime "synced_at"
  end

  create_table "editions_formats", id: false, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer "edition_id", null: false
    t.integer "format_id", null: false
    t.index ["edition_id", "format_id"], name: "ix_edition_id_format_id", unique: true
    t.index ["edition_id"], name: "index_editionss_formats_on_edition_id"
    t.index ["format_id"], name: "ix_format_id"
  end

  create_table "follows", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer "followable_id", null: false
    t.string "followable_type", null: false
    t.integer "follower_id", null: false
    t.string "follower_type", null: false
    t.boolean "blocked", default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["followable_id", "followable_type"], name: "fk_followables"
    t.index ["follower_id", "follower_type"], name: "fk_follows"
  end

  create_table "format_calc_logs", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.integer "deck_list_id", null: false
    t.string "formats", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "format_card_assignments", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer "format_id", null: false
    t.integer "card_id", null: false
    t.integer "limit", limit: 2
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["card_id", "format_id"], name: "index_format_card_assignments_on_card_id_and_format_id", unique: true
  end

  create_table "formats", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string "name", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "min_deck_size", default: 0, null: false
    t.integer "max_deck_size"
    t.integer "max_copies", default: 4, null: false
    t.boolean "enabled", default: true, null: false
    t.text "description", limit: 16777215
    t.binary "legalities", limit: 16777215
    t.string "format_type"
    t.boolean "auto_queue", default: false, null: false
  end

  create_table "games", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer "duel_id"
    t.integer "game_number"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "winning_deck_list_id"
    t.integer "losing_deck_list_id"
    t.integer "win_on_turn"
    t.integer "winner_decision_count"
    t.integer "winner_action_count"
    t.integer "loser_decision_count"
    t.integer "loser_action_count"
    t.integer "parsed_by"
    t.integer "play_time_sec", null: false
    t.integer "deck_list_on_play_id"
    t.index ["deck_list_on_play_id", "losing_deck_list_id"], name: "index_games_on_deck_list_on_play_id_and_losing_deck_list_id"
    t.index ["deck_list_on_play_id", "winning_deck_list_id"], name: "index_games_on_deck_list_on_play_id_and_winning_deck_list_id"
    t.index ["duel_id"], name: "fk_duel"
    t.index ["losing_deck_list_id"], name: "ix_losing_deck_list_id"
    t.index ["winning_deck_list_id", "losing_deck_list_id"], name: "index_games_on_winning_deck_list_id_and_losing_deck_list_id"
    t.index ["winning_deck_list_id"], name: "ix_winning_deck_list_id"
  end

  create_table "keywords", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci" do |t|
    t.string "name"
    t.boolean "combat_relevant"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "maybe_entries", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer "deck_id", null: false
    t.integer "card_id", null: false
    t.integer "deck_entry_cluster_id", null: false
    t.integer "min_amount", null: false
    t.integer "max_amount", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["card_id"], name: "index_maybe_entries_on_card_id"
    t.index ["deck_entry_cluster_id"], name: "index_maybe_entries_on_deck_entry_cluster_id"
    t.index ["deck_id"], name: "index_maybe_entries_on_deck_id"
  end

  create_table "meta", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string "name"
    t.integer "format_id"
    t.integer "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["format_id"], name: "index_meta_on_format_id"
    t.index ["user_id"], name: "index_meta_on_user_id"
  end

  create_table "meta_fragments", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer "meta_id"
    t.integer "occurances"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "archetype_id", null: false
    t.index ["archetype_id"], name: "index_meta_fragments_on_archetype_id"
    t.index ["meta_id"], name: "index_meta_fragments_on_meta_id"
  end

  create_table "misclassifications", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.integer "expected_id", null: false
    t.integer "predicted_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "deck_list_id"
    t.index ["expected_id"], name: "index_misclassifications_on_expected_id"
    t.index ["predicted_id"], name: "index_misclassifications_on_predicted_id"
  end

  create_table "missmatches", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string "recognized_string"
    t.string "device"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "snapshot_file_name"
    t.string "snapshot_content_type"
    t.integer "snapshot_file_size"
    t.datetime "snapshot_updated_at"
    t.integer "card_id"
  end

  create_table "mulligan_decisions", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer "dealt_hand_id", null: false
    t.boolean "mulligan", null: false
    t.string "source_ip"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.boolean "draw", default: false, null: false
    t.integer "time_taken"
    t.index ["dealt_hand_id"], name: "index_mulligan_decisions_on_dealt_hand_id"
  end

  create_table "not_implementable_reasons", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string "name"
    t.text "description"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "playable_hand_entries", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer "deck_id", null: false
    t.integer "deck_entry_cluster_id", null: false
    t.integer "min_amount", null: false
    t.integer "max_amount", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["deck_entry_cluster_id"], name: "index_playable_hand_entries_on_deck_entry_cluster_id"
    t.index ["deck_id"], name: "index_playable_hand_entries_on_deck_id"
  end

  create_table "price_changes", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer "card_print_id", null: false
    t.string "price_type", null: false
    t.float "original_value", limit: 24, null: false
    t.float "new_value", limit: 24, null: false
    t.float "change_in_percent", limit: 24, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "source"
    t.index ["card_print_id"], name: "index_price_changes_on_card_print_id"
  end

  create_table "processed_commits", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "ratings", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer "format_id"
    t.float "value", limit: 24
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "whr_rating"
    t.integer "whr_uncertainty"
    t.integer "deck_list_id"
    t.integer "elo_rating"
    t.float "exp_rating", limit: 24
    t.index ["deck_list_id"], name: "ix_deck_list_id"
    t.index ["format_id", "deck_list_id"], name: "index_ratings_on_format_id_and_deck_list_id", unique: true
    t.index ["format_id"], name: "index_ratings_on_format_id"
    t.index ["whr_rating"], name: "ix_whr_rating"
  end

  create_table "restricted_cards", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer "card_id", null: false
    t.integer "format_id", null: false
    t.integer "limit", limit: 2
    t.index ["card_id"], name: "index_restricted_cards_on_card_id"
    t.index ["format_id"], name: "index_restricted_cards_on_format_id"
  end

  create_table "rpush_apps", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string "name", null: false
    t.string "environment"
    t.text "certificate"
    t.string "password"
    t.integer "connections", default: 1, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "type", null: false
    t.string "auth_key"
    t.string "client_id"
    t.string "client_secret"
    t.string "access_token"
    t.datetime "access_token_expiration"
  end

  create_table "rpush_feedback", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string "device_token", limit: 64, null: false
    t.datetime "failed_at", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "app_id"
    t.index ["device_token"], name: "index_rpush_feedback_on_device_token"
  end

  create_table "rpush_notifications", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.integer "badge"
    t.string "device_token", limit: 64
    t.string "sound", default: "default"
    t.text "alert"
    t.text "data"
    t.integer "expiry", default: 86400
    t.boolean "delivered", default: false, null: false
    t.datetime "delivered_at"
    t.boolean "failed", default: false, null: false
    t.datetime "failed_at"
    t.integer "error_code"
    t.text "error_description"
    t.datetime "deliver_after"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "alert_is_json", default: false
    t.string "type", null: false
    t.string "collapse_key"
    t.boolean "delay_while_idle", default: false, null: false
    t.text "registration_ids", limit: 16777215
    t.integer "app_id", null: false
    t.integer "retries", default: 0
    t.string "uri"
    t.datetime "fail_after"
    t.boolean "processing", default: false, null: false
    t.integer "priority"
    t.text "url_args"
    t.string "category"
    t.boolean "content_available", default: false
    t.text "notification"
    t.index ["app_id", "delivered", "failed", "deliver_after"], name: "index_rapns_notifications_multi"
    t.index ["delivered", "failed"], name: "index_rpush_notifications_multi"
  end

  create_table "rulings", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer "card_id"
    t.text "text", limit: 16777215
    t.date "date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["card_id"], name: "index_rulings_on_card_id"
  end

  create_table "sideboard_entries", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.integer "card_id"
    t.integer "amount"
    t.string "group_type"
    t.integer "deck_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["card_id", "deck_id"], name: "index_sideboard_entries_on_card_id_and_deck_id", unique: true
    t.index ["card_id"], name: "index_sideboard_entries_on_card_id"
    t.index ["deck_id"], name: "index_sideboard_entries_on_deck_id"
  end

  create_table "sideboard_ins", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.integer "sideboard_plan_id", null: false
    t.integer "card_id", null: false
    t.integer "amount", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "sideboard_outs", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.integer "sideboard_plan_id", null: false
    t.integer "card_id", null: false
    t.integer "amount", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "sideboard_plans", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.integer "archetype_id", null: false
    t.integer "deck_id", null: false
    t.integer "deck_list_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "sideboard_suggestions", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.text "sideboard", null: false
    t.float "score", limit: 24, null: false
    t.integer "deck_id", null: false
    t.string "algo", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "meta_id"
    t.integer "deck_list_id", null: false
  end

  create_table "tournament_results", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer "tournament_id"
    t.integer "wins"
    t.integer "losses"
    t.string "mtgo_nick"
    t.integer "mtggf_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["tournament_id"], name: "index_tournament_results_on_tournament_id"
  end

  create_table "tournaments", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer "format_id"
    t.string "tournament_type"
    t.string "identifier"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["format_id"], name: "index_tournaments_on_format_id"
  end

  create_table "users", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "name", null: false
    t.string "provider", default: "email", null: false
    t.string "uid"
    t.boolean "receive_weekly_report", default: true, null: false
    t.string "access_token"
    t.boolean "sysuser", default: false, null: false
    t.string "worker_queue", default: "new", null: false
    t.boolean "airm_admin", default: false, null: false
    t.boolean "may_add_unimplementable_reasons"
    t.text "tokens"
    t.string "device"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "votes", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci" do |t|
    t.string "votable_type"
    t.bigint "votable_id"
    t.string "voter_type"
    t.bigint "voter_id"
    t.boolean "vote_flag"
    t.string "vote_scope"
    t.integer "vote_weight"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["votable_id", "votable_type", "vote_scope"], name: "index_votes_on_votable_id_and_votable_type_and_vote_scope"
    t.index ["votable_type", "votable_id"], name: "index_votes_on_votable_type_and_votable_id"
    t.index ["voter_id", "voter_type", "vote_scope"], name: "index_votes_on_voter_id_and_voter_type_and_vote_scope"
    t.index ["voter_type", "voter_id"], name: "index_votes_on_voter_type_and_voter_id"
  end

end
