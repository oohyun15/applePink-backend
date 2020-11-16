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
    expect(JSON.parse(response.body)["location_info"]["id"]).to eq(id)
  end

  it "location display test" do
    # 기존에 등록되지 않은 지역일 때
    title = Faker::Address.city
    expect(Location.find_by(title: title).nil?).to eq(true)

    # 그 지역이 새로 생성되고 지역 범위에 상관없이 모두 자기 자신만 나옴
    get "/locations/display", params: {title: title}, headers: {Authorization: @token}
    expect(Location.find_by(title: title).nil?).to eq(false)
    JSON.parse(response.body)["location_info"]["range"].each do |range|
      # 그 범위에 속하는 동네 이름은 자기 자신만 있음.
      expect(range["title"]).to eq([title])
      # 그 범위의 동네 개수는 자기 자신만 있으므로 무조건 1개가 됨
      expect(range["count"]).to eq(1)
    end
    # 위에서 생성한 지역 삭제
    Location.last.delete

    # 이미 등록된 지역의 경우
    location = Location.all.sample
    get "/locations/display", params: {title: location.title}, headers: {Authorization: @token}
    expect(JSON.parse(response.body)["location_info"]["id"]).to eq(location.id)
    
    #기존에 등록되어 있는 데이터를 불러옴
    @alone = [location.title]
    @near = Location.where(position: location.location_near).pluck(:title)
    @normal = Location.where(position: location.location_normal).pluck(:title)
    @far = Location.where(position: location.location_far).pluck(:title)

    #response에 나오는 데이터와 불러온 데이터를 비교함.
    range = JSON.parse(response.body)["location_info"]["range"]
    expect([range[0]["title"], range[0]["count"]]).to eq([@alone, @alone.size])
    expect([range[1]["title"], range[1]["count"]]).to eq([@near, @near.size])
    expect([range[2]["title"], range[2]["count"]]).to eq([@normal, @normal.size])
    expect([range[3]["title"], range[3]["count"]]).to eq([@far, @far.size])
  end

  it "locatiton certificate test" do
    # 지역 이름 중 하나를 임의로 선택함.
    location = Location.all.sample
    # 지역 범위 중 임의로 하나를 선택함.
    range = Faker::Number.between(from: 0, to: 3)
    range_list = ["location_alone", "location_near", "location_normal", "location_far"]
    expire_time = 1.week.from_now
    
    put "/locations/certificate", params: {location: {title: location.title, range: range}}, headers: {Authorization: @token}

    # 현재 유저가 제대로 업데이트 됐는지 확인
    @user = User.find(@user.id)
    expect(@user.location_id).to eq(location.position)
    expect(@user.location_range).to eq(range_list[range])
  end
end