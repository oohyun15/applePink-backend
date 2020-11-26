require 'rails_helper'
require 'active_support'

describe "Review test", type: :request do
  before(:all) do
    # 유저 중 임의의 유저를 선택함.
    @user = User.all.sample
    @id = @user.id
    @email = @user.email

    post "/users/sign_in", params: {user: {email: "#{@email}", password: "test123"}}
    @token =  JSON.parse(response.body)["token"]

    # 리뷰를 달기 위해 임의로 accepted 상태인 booking 생성
    # 본인이 작성한 post에는 booking을 만들 수 없으므로 제외함.
    @post = Post.find((Post.all.ids - [@user.posts&.ids]).sample)
    @booking = Booking.create(user_id: @user.id, post_id: @post.id, title: @post.title,
      body: @post.body, price: @post.price, acceptance: :accepted, start_at: "2020-11-20",
      end_at: "2020-11-30", lent_day: 11, contract: @post.contract, product: @post.product,
      provider_name: @post.user.name, consumer_name: @user.name)
  end

  it "review create test" do
    # booking의 상태가 completed가 아니면 리뷰를 남길 수 없음.
    post "/reviews", params: {review: {body: "좋습니다.", rating: 4.5, booking_id: @booking.id}}, headers: {Authorization: @token}
    expect(response).to have_http_status(:not_acceptable)

    #booking의 상태를 completed로 업데이트함.
    @booking.update!(acceptance: :completed)
    post "/reviews", params: {review: {body: "좋습니다.", rating: 4.5, booking_id: @booking.id}}, headers: {Authorization: @token}
    expect(response).to have_http_status(:ok)
  end

  it "review index test" do
    
  end
end
