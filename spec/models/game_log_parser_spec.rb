require 'rails_helper'

describe "GameLogParser", :type => :model do
  it "parsing a sample file works" do
     parser = GameLogParser.new(File.read(Rails.root+"test/assets/game1.log"))
     expected = JSON.parse(File.read(Rails.root+"test/assets/game1.json"))
     assert_equal JSON.pretty_generate(JSON.parse(parser.to_json)), JSON.pretty_generate(expected)
     assert_equal "1.70", parser.meta_data[:magarena_version]
     assert_equal 17,  parser.meta_data[:win_by_turn]
     assert_equal 113, parser.meta_data[:players][:C][:decision_count]
     assert_equal 43,  parser.meta_data[:players][:C][:action_count]
     assert_equal 113, parser.meta_data[:players][:P][:decision_count]
     assert_equal 33,  parser.meta_data[:players][:P][:action_count]
   end
  it "parsing another sample file works" do
     parser = GameLogParser.new(File.read(Rails.root+"test/assets/game2.log"))
     expected = JSON.parse(File.read(Rails.root+"test/assets/game2.json"))
     assert_equal JSON.pretty_generate(JSON.parse(parser.to_json)), JSON.pretty_generate(expected)
     assert_equal 32,  parser.meta_data[:win_by_turn]
     assert_equal 309, parser.meta_data[:players][:C][:decision_count]
     assert_equal 102, parser.meta_data[:players][:C][:action_count]
     assert_equal 173, parser.meta_data[:players][:P][:decision_count]
     assert_equal 56,  parser.meta_data[:players][:P][:action_count]
   end
  it "parsing a 3rd sample file works" do
     parser = GameLogParser.new(File.read(Rails.root+"test/assets/game3.log"))
     expected = JSON.parse(File.read(Rails.root+"test/assets/game3.json"))
     assert_equal JSON.pretty_generate(JSON.parse(parser.to_json)), JSON.pretty_generate(expected)
     assert_equal parser.meta_data[:win_by_turn], 12
   end

end
