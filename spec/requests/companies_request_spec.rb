require 'rails_helper'
require 'active_support'

describe "Company test", type: :request do
  before(:all) do
    # 유저 중 임의의 유저를 선택함.
    @user = User.all.sample
    @id = @user.id
    @email = @user.email

    post "/users/sign_in", params: {user: {email: "#{@email}", password: "test123"}}
    @token =  JSON.parse(response.body)["token"]
  end

  it "Company create test" do
    company_info = {
      company: {
        name: Faker::Name.first_name,
        phone: Faker::Base.numerify('010########'),
        message: "광고주 신청합니다.",
        description: ,
        image: File.open("#{Rails.root}/public/image/default.png"),
        location_id: ,
      }
    }
  end

  it "Company destroy test" do
    
  end

  it "Company confirm test" do
    
  end
end