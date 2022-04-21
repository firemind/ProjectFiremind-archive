# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :restricted_card do
    card_id 1
    format_id 1
    limit 1
  end
end
