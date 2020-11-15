require 'rails_helper'
require 'active_support'

describe "Booking test", type: :request do
  before(:all) do
    # 유저 중 임의의 유저를 선택함.
    @user = User.all.sample
    @id = @user.id
    @email = @user.email

    post "/users/sign_in", params: {user: {email: "#{@email}", password: "test123"}}
    @token =  JSON.parse(response.body)["token"]
  end
  
  it "booking index test" do
    # 유저의 received_booking 목록을 먼저 가져옴.
    received_booking_list = @user.received_bookings.pluck(:id)
    
    get "/bookings", params: {received: "true"}, headers: {Authorization: @token}
    ids = []
    JSON.parse(response.body).each do |booking| 
      ids << booking["booking_info"]["id"]
    end
    expect(received_booking_list).to eq(ids)

    # 유저의 booking 목록을 먼저 가져옴.
    booking_list = @user.bookings.pluck(:id)
    
    get "/bookings", headers: {Authorization: @token}
    ids = []
    JSON.parse(response.body).each do |booking| 
      ids << post["booking_info"]["id"]
    end
    expect(booking_list).to eq(ids)
  end

  it "booking create test" do
    # 자신의 게시글에 대해서는 예약을 생성할 수 없게 설정함.
    user_post_ids = @user.posts.ids
    post_id = user_post_ids.sample
    post "/bookings", params: { booking: {post_id: post_id} }, headers: {Authorization: @token}
    expect(response).to have_http_status(:bad_request)

    # 자신의 게시글을 제외한 게시글 불러오기
    post_ids = Post.all.ids - user_post_ids
    post_id = post_ids.sample

    booking_info = {booking: {start_at: "2020-11-11", end_at: "2020-11-17", post_id: post_id}}
    post "/bookings", params: booking_info, headers: {Authorization: @token}
    expect(response).to have_http_status(:ok)
  end

  it "booking show test" do
    # 마지막 Booking의 id가 위에서 생성된 booking임.
    id = Booking.last.id
    get "/bookings/#{id}", headers: {Authorization: @token}
    expect(JSON.parse(response.body)["booking_info"]["id"]).to eq(id)
  end

  it "booking delete test" do
    # 마지막 Booking의 id가 위에서 생성된 booking임.
    id = Booking.last.id
    delete "/bookings/#{id}", headers: {Authorization: @token}
    expect(response).to have_http_status(:ok)
  end

end