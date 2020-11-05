FactoryBot.define do
  factory :user_push_notification_device do
    user_id { 1 }
    push_notification_device_id { 1 }
  end

  factory :push_notification_device do
    device_type { 1 }
    device_token { "MyString" }
  end

  factory :question do
    
  end


  passwd_array = ["test1231", "test1232", "test1233", "test1234", "test1235"]

  factory :random_user, class: User do
    email { Faker::Internet.unique.email }
    nickname { Faker::Name.unique.name }
    password { passwd_array.sample }
  end
end