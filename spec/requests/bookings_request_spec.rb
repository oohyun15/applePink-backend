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

    # 다른 사용자로 로그인 함.
    @other_user = User.all.where("id != #{@user.id}").sample
    post "/users/sign_in", params: {user: {email: "#{@other_user.email}", password: "test123"}}
    @other_token =  JSON.parse(response.body)["token"]

    # 다른 사용자로 예약을 만듦.
    post = @user.posts.sample
    booking_info = {booking: {start_at: "2020-11-14", end_at: "2020-11-1", post_id: post.id}}
    post "/bookings", params: booking_info, headers: {Authorization: @other_token}
    @booking = Booking.find(JSON.parse(response.body)["booking_info"]["id"])
  end
  
  it "booking index test" do
    # 유저의 received_booking 목록을 먼저 가져옴.
    received_booking_list = @user.received_bookings.pluck(:id)
    
    get "/bookings", params: {received: "true"}, headers: {Authorization: @token}
    ids = []
    JSON.parse(response.body).each do |booking| 
      ids << booking["booking_info"]["id"]
    end
    expect(received_booking_list - ids).to eq([])

    # 유저의 booking 목록을 먼저 가져옴.
    booking_list = @user.bookings.pluck(:id)
    
    get "/bookings", headers: {Authorization: @token}
    ids = []
    JSON.parse(response.body).each do |booking| 
      ids << booking["booking_info"]["id"]
    end
    expect(booking_list - ids).to eq([])
  end

  it "booking new test" do
    # post에 이미 현재 사용자의 booking이 있을 경우에는 그 booking을 반환하고
    # 없는 경우에는 nil 값을 반환한다.
    post = Post.all.sample
    get "/bookings/new", params: {post_id: post.id}, headers: {Authorization: @token}
    if post.bookings.find_by(user_id: @id, acceptance: :waiting).present?
      expect(@user.bookings.ids.include? JSON.parse(response.body)["booking_info"]["id"]).to eq(true)
    else
      expect(JSON.parse(response.body)).to eq(nil)
    end
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

  it "booking accept test" do
    # 처음 생성했을 땐 대기 상태
    expect(@booking.acceptance).to eq("waiting")

    # 예약을 거절하는 경우
    put "/bookings/#{@booking.id}/accept", params: {booking: {acceptance: "rejected"}}, headers: {Authorization: @token}
    expect(Booking.find(@booking.id).acceptance).to eq("rejected")

    # 예약을 승인하는 경우
    put "/bookings/#{@booking.id}/accept", params: {booking: {acceptance: "accepted"}}, headers: {Authorization: @token}
    expect(Booking.find(@booking.id).acceptance).to eq("accepted")
  end

  it "booking complete test" do
    post = @booking.post
    # 예약이 승인된 상태가 아니면 complete할 수 없음.
    @booking = Booking.find(@booking.id)
    unless @booking.accepted?
      expect(response).to have_http_status(:bad_request)
    else
      # booking의 상태가 rent(대여 중)가 아니면 complete할 수 없음.
      put "/bookings/#{@booking.id}/complete", params: {booking: { post_id: post.id}}, headers: {Authorization: @token}
      expect(response).to have_http_status(:bad_request)

      # 예약 상태를 rent로 업데이트.
      @booking.update!(acceptance: :rent)
      put "/bookings/#{@booking.id}/complete", params: {booking: { post_id: post.id}}, headers: {Authorization: @token}
      
      # 예약 상태 completed로 업데이트
      expect(Booking.find(@booking.id).acceptance).to eq("completed")
      # rent 횟수 증가
      expect(Post.find(post.id).rent_count).to eq(post.rent_count + 1)
    end

    delete "/bookings/#{@booking.id}", headers: {Authorization: @other_token}
  end

end