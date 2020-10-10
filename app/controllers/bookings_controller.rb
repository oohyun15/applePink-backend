class BookingsController < ApplicationController
  before_action :authenticate_user!
  before_action :load_post
  before_action :load_book


  private
  def load_post
    begin
      @post = Post.find(params[:post_id])
    rescue => e
      render json: {error: "없는 게시글입니다."}, status: :bad_request
    end
  end

  def load_book
    begin
      @book = Post.find(params[:id])
    rescue => e
      render json: {error: "없는 예약입니다."}, status: :bad_request
    end
  end
end
