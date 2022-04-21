FactoryGirl.define do
  factory :duel_queue do
    name "default"
    magarena_version_major 4
    magarena_version_minor 2
    ai1_strength 6
    ai2_strength 6
    ai1 "TEST"
    ai2 "TEST"
    life 42
    active true
  end
end
