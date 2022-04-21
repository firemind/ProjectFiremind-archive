# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :deck_list do
    udi "MyString"
    archetype_id 1
    colors "MyString"
  end
end
