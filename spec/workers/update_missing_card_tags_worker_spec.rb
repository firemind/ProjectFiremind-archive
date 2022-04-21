require 'rails_helper'

describe "UpdateMissingCardTagsWorker", :type => :model do
  it "adding first tag works" do
    user = FactoryGirl.create :user
    card = Card.find_by_name "War Elephant"
    card.config_updater = user
    card.save
    banding  = FactoryGirl.create :not_implementable_reason, name: "banding", description: "Banding is weird", user: user

    repo_base_path = Rails.configuration.x.missing_cards_repo_path
    FileUtils.rm_r(repo_base_path) if File.exists?(repo_base_path)
    FileUtils.mkdir_p(repo_base_path)
    g=  Git.init(repo_base_path.to_s)
    missing_scripts_path = File.join repo_base_path, "/release/Magarena/scripts_missing/"

    FileUtils.mkdir_p(missing_scripts_path)
    FileUtils.cp('test/assets/War_Elephant.txt', missing_scripts_path)

    card.not_implementable_reasons << banding
    card.save
    UpdateMissingCardTagsWorker.new.perform(card.id)

    expected_script_file = missing_scripts_path+"/War_Elephant.txt"
    expect(File).to exist(expected_script_file) 
    expect(File.read(expected_script_file)).to match <<-TXT
name=War Elephant
image=http://mtgimage.com/card/war%20elephant.jpg
value=2.500
rarity=C
type=Creature
subtype=Elephant
cost={3}{W}
pt=2/2
ability=Trample; banding
timing=main
oracle=Trample; banding
status=not supported: banding
TXT
    expect(g.status.changed.size).to eq 0
    expect(g.log.first.author.email).to eq(user.email)
    expect(g.log.first.message).to eq("Update missing card status for War Elephant")
  end

  it "adding an additional tag works" do
    user = FactoryGirl.create :user
    card = Card.find_by_name "Icatian Phalanx"
    card.config_updater = user
    card.save
    banding  = FactoryGirl.create :not_implementable_reason, name: "banding", description: "Banding is weird", user: user
    card.not_implementable_reasons << banding
    other_reason = FactoryGirl.create :not_implementable_reason, name: "other-reason", description: "Just another reason", user: user

    repo_base_path = Rails.configuration.x.missing_cards_repo_path
    FileUtils.rm_r(repo_base_path) if File.exists?(repo_base_path)
    FileUtils.mkdir_p(repo_base_path)
    g=  Git.init(repo_base_path.to_s)
    missing_scripts_path = File.join repo_base_path, "/release/Magarena/scripts_missing/"

    FileUtils.mkdir_p(missing_scripts_path)
    FileUtils.cp('test/assets/Icatian_Phalanx.txt', missing_scripts_path)

    card.not_implementable_reasons << other_reason
    card.save
    UpdateMissingCardTagsWorker.new.perform(card.id)

    expected_script_file = missing_scripts_path+"/Icatian_Phalanx.txt"
    expect(File).to exist(expected_script_file) 
    expect(File.read(expected_script_file)).to match <<-TXT
name=Icatian Phalanx
image=http://magiccards.info/scans/en/me2/16.jpg
value=2.135
rarity=C
type=Creature
subtype=Human,Soldier
cost={4}{W}
pt=2/4
ability=Banding
timing=main
oracle=Banding
status=not supported: banding, other-reason
TXT
    expect(g.status.changed.size).to eq 0
    expect(g.log.first.author.email).to eq(user.email)
    expect(g.log.first.message).to eq("Update missing card status for Icatian Phalanx")
  end
end
