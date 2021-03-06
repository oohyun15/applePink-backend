require 'rails_helper'

describe "User test", type: :request do
  before(:all) do
    user = User.all.sample
    @id = user.id
    @email = user.email

    post "/api/users/sign_in", params: {user: {email: "#{@email}", password: "test123"}}
    @token =  JSON.parse(response.body)["token"]
  end

  # JWT 토큰이 유효한지 확인
  xit 'user sign_in test => token validation' do
    auth_token ||= JsonWebToken.decode(@token)
    expect(auth_token[:user_id].to_i).to eq(@id)
  end

  # sign_up 이전에는 tonem123@naver.com 이메일을 가진 유저가 없음
  # sign_up 이후에는 유저가 생성됨.
  xit 'user create test' do
    expect(User.where(email: "tonem123@naver.com").present?).to eq(false)
    post "/api/users/sign_up", params: {user: {email: "tonem123@naver.com", nickname: "tonem123", 
      password: "test123", password_confirmation: "test123"}}
      expect(User.where(email: "tonem123@naver.com").present?).to eq(true)
  end

  #앞선 테스트에서 생성한 유저의 정보를 수정하는 테스트
  xit 'user update test' do
    location = Location.all.sample
    user_before = User.find_by(email: "tonem123@naver.com")
    user_before.update!(location_id: location.id)
    put "/api/users/#{user_before.id}", params: {user: {email: "change123@naver.com", nickname: "change123", 
      password: "change123", password_confirmation: "change123"}}, headers: {Authorization: @token}

    #이전 user id로 객체의 정보가 업데이트 되었는지 확인함.
    user_after = User.find(user_before.id)
    expect(user_after.email).to eq("change123@naver.com")
    expect(user_after.nickname).to eq("change123")
  end

  xit 'user range test' do
    user_before = User.find_by(email: "change123@naver.com")
    post "/api/users/sign_in", params: {user: {email: user_before.email, password: "change123"}}

    before_range = user_before.location_range
    put range_api_users_path, params: {user: {location_range: "location_far"}}, headers: {Authorization: JSON.parse(response.body)["token"]}

    user_after = User.find(user_before.id)
    expect(before_range.eql? user_after.location_range).to eq(false)
    expect(user_after.location_range).to eq("location_far")
  end

  xit 'user withdrawal test' do
    user = User.find_by(email: "change123@naver.com")
    post "/api/users/sign_in", params: {user: {email: user.email, password: "change123"}} 
    delete '/api/users/withdrawal', headers: {Authorization: JSON.parse(response.body)["token"]}
    expect(User.where(id: user.id).present?).to eq(false)
  end

  #전체 유저 목록을 불러오는지 확인
  xit 'user index test' do
    get "/api/users", headers: {Authorization: @token}
    expect(JSON.parse(response.body).size).to eq(User.all.size)
  end

  #선택한 유저 정보를 가져오는 확인
  xit 'user show test' do
    get "/api/users/#{@id}", headers: {Authorization: @token}
    expect(JSON.parse(response.body)["user_info"]["id"]).to eq(@id)
  end

  xit 'user mypage test' do
    get mypage_api_users_path, headers: {Authorization: @token}
    #결과로 나온 user 정보가 로그인한 유저의 정보인지 확인
    expect(JSON.parse(response.body)["user_info"]["id"]).to eq(@id)
  end

  xit 'user list test' do
    get list_api_user_path(@id), params: {post_type: "provide"}, headers: {Authorization: @token}

    posts = Post.where(["user_id = :user_id and post_type = :post_type", { user_id: @id, post_type: 0 }]).ids
    
    # response에서 온 user들의 id와 db에서 query로 직접 뽑아낸 user들의 id를 비교함.
    ids = []
    JSON.parse(response.body).each do |post|
      ids << post["post_info"]["id"]
    end
    expect(posts - ids).to eq([])
  end
  
end