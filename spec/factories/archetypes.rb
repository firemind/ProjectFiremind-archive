# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :archetype do
    name "MyString"

    trait :infect do
      name "Infect"
      format_id 37
      id 1518

    end
    factory :infect_modern,   traits: [:infect]
  end

end
