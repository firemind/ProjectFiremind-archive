require 'rails_helper'

describe "PushCardscriptWorker", :type => :model do
  it "pushing new script works" do
    user  = FactoryGirl.create :user
    card  = FactoryGirl.create :card, name: "test card"
    csm   = FactoryGirl.create :card_script_submission, user: user, card: card

    repo_base_path = Rails.configuration.x.magarena_repo_path
    FileUtils.rm_r(repo_base_path) if File.exists?(repo_base_path)
    FileUtils.mkdir_p(repo_base_path)
    g=  Git.init(repo_base_path.to_s)
    scripts_path = File.join repo_base_path, "/release/Magarena/scripts/"
    FileUtils.mkdir_p(scripts_path)
    PushCardscriptWorker.new.perform(csm.id)
    expected_script_file = scripts_path+"test_card.txt"
    expect(File).to exist(expected_script_file) 
    expect(File.read(expected_script_file)).to eq csm.config
    expected_groovy_file = scripts_path+"test_card.groovy" 
    expect(File).to exist(expected_groovy_file) 
    expect(File.read(expected_groovy_file)).to eq csm.script
    expect(g.status.changed.size).to eq 0
    expect(g.log.first.author.email).to eq(user.email)
    expect(g.log.first.message).to eq("Add script for test card")
  end
end
