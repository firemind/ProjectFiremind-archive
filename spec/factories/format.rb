FactoryGirl.define do
  factory :format do
    trait :modern do
      name "My Modern"
      id 37
      enabled true
    end
 
    factory :modern,   traits: [:modern]
  end
end
