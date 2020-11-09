require 'rails_helper'
require 'active_support'

describe "Post test", type: :request do
  before(:all) do
    # 유저 중 임의의 유저를 선택함.
    user = User.all.sample
    @id = user.id
    @email = user.email

    post "/users/sign_in", params: {user: {email: "#{@email}", password: "test123"}}
    @token =  JSON.parse(response.body)["token"]
  end

  it 'post index test' do
    # 존재하지 않는 지역으로 찾기
    # 404 (Not Found) error 발생
    get "/posts", params: {location_title: "삼성동"}, headers: {Authorization: @token}
    expect(response).to have_http_status(404)

    # response로 넘어온 post들이 랜덤으로 선택된 지역의 post인지 확인
    # 길이가 같은 것으로 확인
    title = Location.all.pluck(:title).sample
    get "/posts", params: {location_title: title}, headers: {Authorization: @token}

    # response에서 온 post들의 id와 db에서 query로 직접 뽑아낸 post들을 id를 비교함.
    posts = Post.where(title: title).ids
    ids = []
    JSON.parse(response.body).each do |post| 
      ids << post["post_info"]["id"]
    end
    expect(posts).to eq(ids)

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

    get "/posts", headers: {Authorization: @token}
    # response에서 온 post들의 id와 db에서 query로 직접 뽑아낸 post들의 id를 비교함.
    posts = Post.where(post_type: :provide, location_id: location_positions).ids

    ids = []
    JSON.parse(response.body).each do |post| 
      ids << post["post_info"]["id"]
    end
    expect(posts).to eq(ids)
    
    get "/posts", params: {post_type: :ask}, headers: {Authorization: @token}
    # response에서 온 post들의 id와 db에서 query로 직접 뽑아낸 post들의 id를 비교함.
    posts = Post.where(post_type: :ask, location_id: location_positions).ids

    ids = []
    JSON.parse(response.body).each do |post| 
      ids << post["post_info"]["id"]
    end
    expect(posts).to eq(ids)
  end

  it "post show test" do
    post_id = Post.all.ids.sample
    
    get "/posts/#{post_id}", headers: {Authorization: @token}
    expect(JSON.parse(response.body)["post_info"]["id"]).to eq(post_id)
  end

  it "post create test" do
    # 생성에 필요한 정보가 없을 때 bad request 상태가 뜸
    post_info = { post: {title: nil, body: "2일부터 8일까지 대여해줍니다.", price: 21000,
      post_type: :provide, category_id: 4} }
      post "/posts", params: post_info, headers: {Authorization: @token}
    expect(response).to have_http_status(400)

    #생성할 post의 정보를 정의함
    post_info = { post: {title: "맥북 15인치 대여합니다.", body: "2일부터 8일까지 대여해줍니다.", price: 21000,
      post_type: :provide, category_id: 4} }
    
    post "/posts", params: post_info, headers: {Authorization: @token}
    expect(response).to have_http_status(200)
  end

  it "post update test" do
    post = Post.last

    update_info = { post: {title: "업데이트", body: "업데이트되어야 함", price: 10000,
      post_type: "ask", category_id: 2} }
    
    # 위의 내용대로 post를 update 함.
    put "/posts/#{post.id}", params: update_info, headers: {Authorization: @token}

    post = Post.last
    expect(post.title).to eq(update_info[:post][:title])
    expect(post.body).to eq(update_info[:post][:body])
    expect(post.price).to eq(update_info[:post][:price])
    expect(post.post_type).to eq(update_info[:post][:post_type])
    expect(post.category_id).to eq(update_info[:post][:category_id])
  end

  it "post delete test" do
    # last id가 위 테스트에서 생성한 post의 id임.
    post_id = Post.last.id

    delete "/posts/#{post_id}", headers: {Authorization: @token}
    expect(response).to have_http_status(200)
  end

  it "post like test" do
    id = Post.all.ids.sample

    # post에 좋아요한 유저의 이름을 반환함
    get "/posts/#{id}/like", headers: {Authorization: @token}
    user_list = JSON.parse(response.body)["user_list"]
    
    # 데이터베이스에서 직접 찾은 내용과 일치하는지 확인
    user_nicknames = Post.find(id).likes.pluck(:user_id)
    expect(user_list).to eq(user_nicknames)
  end
end
