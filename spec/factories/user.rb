FactoryGirl.define do
  factory :user do
    trait :normal do
      email Faker::Internet.email
      nickname "normal_#{Faker::Name.name}"
      password "test123"
      password_confirmation "test123"
      user_type "normal"
    end

    trait :company do
      email Faker::Internet.email
      nickname "company_#{Faker::Name.name}"
      password "test123"
      password_confirmation "test123"
      user_type "company"
    end
  end

  factory :user_normal, class: User, traits: [:normal]
  factory :user_company, class: User, traits: [:company]
end