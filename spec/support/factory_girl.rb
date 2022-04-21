RSpec.configure do |config|
  config.before(:example) do
    @queue ||=(DuelQueue.default || FactoryGirl.create(:duel_queue))
    (User.sysuser || FactoryGirl.create(:user, sysuser: true, email: ""))
  end
end
