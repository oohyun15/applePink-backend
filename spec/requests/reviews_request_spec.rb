require 'rails_helper'
require 'active_support'

describe "Review test", type: :request do
  before(:all) do
    # 유저 중 임의의 유저를 선택함.
    # @user = User.all.sample
    # @id = @user.id
    # @email = @user.email

    # post "/users/sign_in", params: {user: {email: "#{@email}", password: "test123"}}
    # @token =  JSON.parse(response.body)["token"]

    # # 리뷰를 달기 위해 임의로 accepted 상태인 booking 생성
    # # 본인이 작성한 post에는 booking을 만들 수 없으므로 제외함.
    # @post = Post.find((Post.all.ids - [@user.posts&.ids]).sample)
    # @booking = Booking.create(user_id: @user.id, post_id: @post.id, title: @post.title,
    #   body: @post.body, price: @post.price, acceptance: :accepted, start_at: "2020-11-20",
    #   end_at: "2020-11-30", lent_day: 11, contract: @post.contract, product: @post.product,
    #   provider_name: @post.user.name, consumer_name: @user.name)
  end

  xit "review create test" do
    # booking의 상태가 completed가 아니면 리뷰를 남길 수 없음.
    review_info = {review: {body: "좋습니다.", rating: 4.5, booking_id: @booking.id}}
    post "/reviews", params: review_info, headers: {Authorization: @token}
    expect(response).to have_http_status(:not_acceptable)

    #booking의 상태를 c ompleted로 업데이트함.
    @booking.update!(acceptance: :completed)
    post "/reviews", params: {review: {body: "좋습니다.", rating: 4.5, booking_id: @booking.id}}, headers: {Authorization: @token}
    expect(response).to have_http_status(:ok)

    # 리뷰를 단 게시글의 평점을 가져옴.
    post = Post.find(@booking.post_id)
    # 현재 게시글의 평균 평점이 게시글 리뷰의 모든 평점의 평균과 같은지 확인함.
    expect(post.rating_avg).to eq(post.reviews.average(:rating).to_f)
  end

  xit "review index test" do
    user = User.all.sample
    post = Post.all.sample
    get "/reviews?user_id=#{user.id}", headers: {Authorization: @token}
    if user.reviews.empty?
      expect(JSON.parse(response.body)).to eq([])
    else
      reviews = user.reviews.ids
      ids = []
      JSON.parse(response.body).each do |review|
        ids << review["review_info"]["id"]
      end
      expect(reviews - ids).to eq([])
    end

    get "/reviews?user_id=#{user.id}&received=true", headers: {Authorization: @token}
    if user.received_reviews.empty?
      expect(JSON.parse(response.body)).to eq([])
    else
      reviews = user.received_reviews.ids
      ids = []
      JSON.parse(response.body).each do |review|
        ids << review["review_info"]["id"]
      end
      expect(reviews - ids).to eq([])
    end

    get "/reviews?post_id=#{post.id}", headers: {Authorization: @token}
    if post.reviews.empty?
      expect(JSON.parse(response.body)).to eq([])
    else
      reviews = post.reviews.ids
      ids = []
      JSON.parse(response.body).each do |review|
        ids << review["review_info"]["id"]
      end
      expect(reviews - ids).to eq([])
    end
  end

  xit "review update test" do
    review = Review.all.sample
    review_info = {review: {body: "수정 내용", rating: 3.0, booking_id: @booking.id}}
    if review.user != @user
      # 본인이 작성한 리뷰가 아닐 경우 에러가 발생함.
      put "/reviews/#{review.id}", params: review_info, headers: {Authorization: @token}
      expect(response).to have_http_status(:unauthorized)
    else
      # 리뷰를 수정함.
      put "/reviews/#{review.id}", params: review_info, headers: {Authorization: @token}
      res = JSON.parse(response.body)["review_info"]

      expect(res["body"]).to eq(review_info[:review][:body])
      expect(res["rating"]).to eq(review_info[:review][:rating])
      # 리뷰를 단 게시글의 평점을 가져옴.
      post = Post.find(@booking.post_id)
      # 현재 게시글의 평균 평점이 게시글 리뷰의 모든 평점의 평균과 같은지 확인함.
      expect(post.rating_avg).to eq(post.reviews.average(:rating).to_f)
    end
  end

  xit "review delete test" do
    review = Review.all.sample

    delete "/reviews/#{review.id}", headers: {Authorization: @token}
    if review.user != @user
      # 본인이 작성한 리뷰가 아닐 경우 에러가 발생함.
      expect(response).to have_http_status(:unauthorized)
    else
      expect(Review.find_by(id: review.id)).to eq(nil)
    end

    Booking.find(@booking.id).delete
  end
end
