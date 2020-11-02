FactoryBot.define do

  passwd_array = ["test1231", "test1232", "test1233", "test1234", "test1235"]

  factory :random_user, class: User do
    email { Faker::Internet.unique.email }
    nickname { Faker::Name.unique.name }
    password { passwd_array.sample }
  end
end