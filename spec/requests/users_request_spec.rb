require 'rails_helper'

describe "Get Users", type: :request do
  #let!(:users) {FactoryBot.create_list(:random_user, 5)}

  before {get '/users'}
  #전체 유저 목록을 불러오는지 확인
  it 'returns all users' do
    expect(JSON.parse(response.body).size).to eq(User.all.size)
  end

  #status가 200인지 확인
  it 'returns status code 200' do
    expect(response).to have_http_status(:success)
  end
  
end

describe "Users sign_up test", type: :request do

  before { post '/users/sign_up', params: {user: {email: "tonem123@naver.com", nickname: "tonem123", 
    password: "test123", password_confirmation: "test123"}} }
  
  #현재 sign_up 후 sign_in_path로 redirect 중
  #devise는 Get Method에 대해서 200이 아닌 302(Found)를 반환함
  it 'returns status code 302' do
    expect(response).to have_http_status(302)
  end
end

describe "Users sign_in test", type: :request do
  #let!(:users) {FactoryBot.create_list(:random_user, 5)}

  before {post '/users/sign_in', params: {user: {email: "tester1@test.com", password: "test123"}} }
  # 로그인 후 JWT 토큰이 유효한지 확인
  it 'is_token_validates' do
    body =  JSON.parse(response.body)
    auth_token ||= JsonWebToken.decode(body["token"])
    expect(auth_token[:user_id].to_i).to eq(User.find_by(email: "tester1@test.com").id)
  end
  
end

describe "Users withdrawal test", type: :request do
  #let!(:users) {FactoryBot.create_list(:random_user, 5)}
  
  before {post '/users/sign_in', params: {user: {email: "tonem123@naver.com", password: "test123"}} }

  before {delete '/users/withdrawal'}

  # 로그인 후 JWT 토큰이 유효한지 확인
  it 'user_deleted?' do
    expect(User.find_by(email: "tonem123@naver.com")).to eq(nil)
  end
  
end