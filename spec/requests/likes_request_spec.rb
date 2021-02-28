require 'rails_helper'
require 'active_support'

describe "Like test", type: :request do
  before(:all) do
    # 유저 중 임의의 유저를 선택함.
    @user = User.all.sample
    @id = @user.id
    @email = @user.email

    post "/users/sign_in", params: {user: {email: "#{@email}", password: "test123"}}
    @token =  JSON.parse(response.body)["token"]
  end

  xit "Like index test" do
    user = User.all.sample

    # 전체 좋아요 목록 보기
    get "/users/#{user.id}/likes", headers: {Authorization: @token}
    likes = user.likes.ids

    ids = []
    JSON.parse(response.body).each do |like|
      ids << like["like_info"]["id"]
    end
    expect(likes - ids).to eq([])

    # 특정 타입에 한 좋아요 목록 보기
    type = ["user", "post", "location"].sample
    get "/users/#{user.id}/likes", params: {target_type: type}, headers: {Authorization: @token}

    likes = user.likes.where(target_type: type.capitalize).ids

    ids = []
    JSON.parse(response.body).each do |like|
      ids << like["like_info"]["id"]
    end
    expect(likes - ids).to eq([])
  end
  
  xit "Like toggle test" do
    # 좋아요 할 수 없는 type 선택 시 에러 발생
    type = "company"
    id = Company.all.ids.sample
    post "/users/like", params: {like: {target_id: id, target_type: type}}, headers: {Authorization: @token}
    expect(response).to have_http_status(:bad_request)

    type = ["user", "post", "location"].sample.capitalize
    target = type.constantize.all.sample

    # like의 대상이 자기 자신이거나 자신이 작성한 게시물일 경우 에러
    if (target.user rescue target) == @user
      expect(response).to have_http_status(:bad_request)
    else
      # 기존에 좋아요를 한 대상일 경우
      if like = @user.likes.find_by(target_type: type, target_id: target.id)
        post "/users/like", params: {like: {target_type: type, target_id: target.id}}, headers: {Authorization: @token}
        expect(JSON.parse(response.body)["result"]).to eq("false")
      else
        post "/users/like", params: {like: {target_type: type, target_id: target.id}}, headers: {Authorization: @token}
        expect(JSON.parse(response.body)["result"]).to eq("true")
      end
    end
  end
end