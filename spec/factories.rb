FactoryGirl.define do
  factory :user do
    sequence :email do |n|
      "person#{n}@firemind.ch"
    end
    name  "mike"
    password "secretsecret"
    password_confirmation "secretsecret"
  end

  factory :game do
    play_time_sec 190
    game_number 1
  end

  factory :card do
    name "Akroma, Angel of Wrath"
    cmc 8
    card_type 'Creature'
  end

end
