require 'test_helper'

class DuelsControllerTest < ActionController::TestCase
  setup do
    @duel = duels(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:duels)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create duel" do
    assert_difference('Duel.count') do
      post :create, duel: { deck1_id: @duel.deck1_id, deck1_text: @duel.deck1_text, deck2_id: @duel.deck2_id, deck2_text: @duel.deck2_text, games: @duel.games, games_played: @duel.games_played, state: @duel.state, user_id: @duel.user_id, wins_deck1: @duel.wins_deck1 }
    end

    assert_redirected_to duel_path(assigns(:duel))
  end

  test "should show duel" do
    get :show, id: @duel
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @duel
    assert_response :success
  end

  test "should update duel" do
    patch :update, id: @duel, duel: { deck1_id: @duel.deck1_id, deck1_text: @duel.deck1_text, deck2_id: @duel.deck2_id, deck2_text: @duel.deck2_text, games: @duel.games, games_played: @duel.games_played, state: @duel.state, user_id: @duel.user_id, wins_deck1: @duel.wins_deck1 }
    assert_redirected_to duel_path(assigns(:duel))
  end

  test "should destroy duel" do
    assert_difference('Duel.count', -1) do
      delete :destroy, id: @duel
    end

    assert_redirected_to duels_path
  end
end
