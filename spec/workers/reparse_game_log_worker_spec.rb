require 'rails_helper'

describe "ReparseGameLogWorker", :type => :model do
  it "reparse a game log works" do
    user  = FactoryGirl.create :user
    deck1 = FactoryGirl.create :naya_deck, {author: user}
    deck2 = FactoryGirl.create :gruul_deck, {author: user}
    deck1.deck_list.formats << Format.modern
    deck2.deck_list.formats << Format.modern
    duel = FactoryGirl.create :duel_with_games, {format_id: 4, deck_list1: deck1.deck_list, deck_list2: deck2.deck_list}
    game = Game.last

    path = LOGFILE_BASEDIR+game.log_path
    FileUtils.mkdir_p File.dirname(path)
    `cp test/assets/game1.log.gz #{path}.gz`

    ReparseGameLogWorker.new.perform game.id
    input = Zlib::GzipReader.new(open(path+".gz"))
    parser = GameLogParser.new(input)
    expected = JSON.parse(File.read(Rails.root+"test/assets/game1.json"))
    assert_equal JSON.pretty_generate(JSON.parse(parser.to_json)), JSON.pretty_generate(expected)

    game.reload
    assert_equal 113,   game.winner_decision_count
    assert_equal 33,   game.winner_action_count
    assert_equal 113,   game.loser_decision_count
    assert_equal 43,   game.loser_action_count
    assert_equal 1,    game.duel.magarena_version_major
    assert_equal 70,   game.duel.magarena_version_minor
    assert_equal GameLogParser::VERSION,   game.parsed_by
  end
end

