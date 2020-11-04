require 'rails_helper'

describe "User test", type: :request do
  before(:all) do
    @id = User.first.id
    @email = User.first.email

    post "/users/sign_in", params: {user: {email: "#{@email}", password: "test123"}}
    @token =  JSON.parse(response.body)["token"]
  end

  #현재 sign_up 후 sign_in_path로 redirect 중
  #devise는 Get Method에 대해서 200이 아닌 302(Found)를 반환함
  it 'user sign_up test' do
    post "/users/sign_up", params: {user: {email: "tonem123@naver.com", nickname: "tonem123", 
      password: "test123", password_confirmation: "test123"}}
    expect(response).to have_http_status(302)
  end

  #앞선 테스트에서 생성한 유저의 정보를 수정하는 테스트
  it 'user update test' do
    u = User.find_by(email: "tonem123@naver.com")
    put "/users/#{u.id}", params: {user: {email: "change123@naver.com", nickname: "change123", 
      password: "change123", password_confirmation: "change123"}}, headers: {Authorization: @token}

    #이전 user id로 객체의 정보가 업데이트 되었는지 확인함.
    expect(User.find(u.id).email).to eq("change123@naver.com")
  end

  it 'user withdrawal test' do
    u = User.find_by(email: "change123@naver.com")
    post "/users/sign_in", params: {user: {email: u.email, password: "change123"}} 
    delete '/users/withdrawal', headers: {Authorization: JSON.parse(response.body)["token"]}
    expect(User.where(id: u.id).present?).to eq(false)
  end

  #전체 유저 목록을 불러오는지 확인
  it 'user index test' do
    get "/users"
    expect(JSON.parse(response.body).size).to eq(User.all.size)
  end

  #선택한 유저 정보를 가져오는 확인
  it 'user show test' do
    get "/users/#{@id}", headers: {Authorization: @token}
    expect(JSON.parse(response.body)["user_info"]["id"]).to eq(@id)
  end

  # 로그인 후 JWT 토큰이 유효한지 확인
  it 'user sign_in test => token validation' do
    auth_token ||= JsonWebToken.decode(@token)
    expect(auth_token[:user_id].to_i).to eq(User.find_by(email: @email).id)
  end

  it 'user mypage test' do
    get mypage_users_path, headers: {Authorization: @token}
    #결과로 나온 user 정보가 로그인한 유저의 정보인지 확인
    expect(JSON.parse(response.body)["user_info"]["id"]).to eq(User.find_by(email: @email).id)
  end

  it 'user list test' do
    get list_user_path id: @id, params: {post_type: "provide"}, headers: {Authorization: @token}
    posts = JSON.parse(response.body)["posts"]

    #결과로 나온 post들의 post_type이 모두 "provide인지 확인"
    is_provide = true
    
    #post들이 나오지 않을 땐 바로 테스트 통과시키기
    unless posts == nil
      for i in 0..(posts.length - 1)
        if posts[i]["post_type"] != "provide"
          is_provide = false
        end
      end
    end
    expect(is_provide).to eq(true)
  end
end