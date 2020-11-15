require 'rails_helper'
require 'active_support'

describe "Location test", type: :request do
  before(:all) do
    # 유저 중 임의의 유저를 선택함.
    @user = User.all.sample
    @id = @user.id
    @email = @user.email

    post "/users/sign_in", params: {user: {email: "#{@email}", password: "test123"}}
    @token =  JSON.parse(response.body)["token"]
  end
  
  it "location index test" do 
    get "/locations", headers: {Authorization: @token}
    expect(JSON.parse(response.body).size).to eq(Location.all.size)
  end

  it "location show test" do
    id = Location.all.ids.sample
    get "/locations/#{id}", headers: {Authorization: @token}
    expect(JSON.parse(response.body)["id"]).to eq(id)
  end

  it "locatiton certificate test" do
    # 지역 이름 중 하나를 임의로 선택함.
    title = Location.all.pluck(:title).sample

    put "/locations/certificate", params: {location: {title: title}}, headers: {Authorization: @token}
  end
end