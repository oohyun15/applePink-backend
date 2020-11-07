require 'rails_helper'
require 'active_support'

describe "Post test", type: :request do
  before(:all) do
    @id = User.last.id
    @email = User.last.email

    post "/users/sign_in", params: {user: {email: "#{@email}", password: "test123"}}
    @token =  JSON.parse(response.body)["token"]
  end

  it 'post index test' do
    # 존재하지 않는 지역으로 찾기
    # 404 (Not Found) error 발생
    get "/posts", params: {location_title: "삼성동"}, headers: {Authorization: @token}
    expect(response).to have_http_status(404)

    # response로 넘어온 post들이 "파장동" post인지 확인
    # 길이가 같은 것으로 확인
    get "/posts", params: {location_title: "파장동"}, headers: {Authorization: @token}
    unless JSON.parse(response.body).empty?
      posts = JSON.parse(response.body).select { |post| post["post_info"]["location"] == "파장동" }
      expect(posts.length).to eq(JSON.parse(response.body).length)
    end

    get "/posts", headers: {Authorization: @token}
    
    # 사용자 거리 설정에 따라 index로 나오는 post의 결과가 달라짐.
    user = User.find(@id)
    location_positions = []
    location = user.location
    case user.location_range
    when "location_alone"
      location_positions << location.position
    when "location_near"
      location_positions = location.location_near
    when "location_normal"
      location_positions = location.location_normal
    when "location_far"
      location_positions = location.location_far
    end

    posts = Post.where(post_type: :provide, location_id: location_positions)
    expect(posts.length).to eq(JSON.parse(response.body).length)
    
    posts = JSON.parse(response.body).select { |post| post["post_info"]["location_id"].in? location_positions }
    expect(posts.length).to eq(JSON.parse(response.body).length)
  end
end
