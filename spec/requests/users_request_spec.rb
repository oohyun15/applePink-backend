require 'rails_helper'

describe "1. User #index test", type: :request do
  before {get '/users'}
  #전체 유저 목록을 불러오는지 확인
  it 'returns all users' do
    expect(JSON.parse(response.body).size).to eq(User.all.size)
  end
end

describe "2. User #show test", type: :request do
  before { post '/users/sign_in', params: {user: {email: "tester1@test.com", password: "test123"}} }
  #전체 유저 목록을 불러오는지 확인
  it 'returns selected user' do
    body =  JSON.parse(response.body)
    get '/users/2', headers: {Authorization: body["token"]}

    expect(JSON.parse(response.body)["user_info"]["id"]).to eq(2)
  end
end

describe "3. User #sign_up test", type: :request do
  #현재 sign_up 후 sign_in_path로 redirect 중
  #devise는 Get Method에 대해서 200이 아닌 302(Found)를 반환함
  it 'returns status code 302' do
    post '/users/sign_up', params: {user: {email: "tonem123@naver.com", nickname: "tonem123", 
      password: "test123", password_confirmation: "test123"}}
    expect(response).to have_http_status(302)
  end
end

describe "4. User #sign_in test", type: :request do
  # 로그인 후 JWT 토큰이 유효한지 확인
  it 'is_token_validates' do
    post '/users/sign_in', params: {user: {email: "tester1@test.com", password: "test123"}}
    body =  JSON.parse(response.body)
    @token = body["token"]
    auth_token ||= JsonWebToken.decode(body["token"])
    expect(auth_token[:user_id].to_i).to eq(User.find_by(email: "tester1@test.com").id)
  end
end

describe "5. User #withdrawal test", type: :request do
  # 로그인 후 JWT 토큰이 유효한지 확인
  it 'user_deleted?' do
    post '/users/sign_in', params: {user: {email: "tonem123@naver.com", password: "test123"}}
    body =  JSON.parse(response.body)

    delete '/users/withdrawal', headers: {Authorization: body["token"]}
    expect(User.find_by(email: "tonem123@naver.com")).to eq(nil)
  end
end

describe "6. User #mypage test", type: :request do
  it 'current_user test' do
    post '/users/sign_in', params: {user: {email: "tester1@test.com", password: "test123"}}
    body =  JSON.parse(response.body)
    
    get mypage_users_path, headers: {Authorization: body["token"]}
    #결과로 나온 user 정보가 로그인한 유저의 정보인지 확인
    expect(JSON.parse(response.body)["user_info"]["id"]).to eq(User.find_by(email: "tester1@test.com").id)
  end
end

describe "7. User #list test", type: :request do
  it 'post_type test' do
    post '/users/sign_in', params: {user: {email: "tester1@test.com", password: "test123"}}
    body =  JSON.parse(response.body)
    
    get list_users_path, params: {post_type: "provide"}, headers: {Authorization: body["token"]}
    posts = JSON.parse(response.body)["posts"]

    #결과로 나온 post들의 post_type이 모두 "provide인지 확인"
    is_provide = true
    for i in 0..(posts.length - 1)
      if posts[i]["post_type"] != "provide"
        is_provide = false
      end
    end
    expect(is_provide).to eq(true)
  end
end