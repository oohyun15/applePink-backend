class UsersController < ApplicationController
  before_action :load_user, only: %i(show edit update destroy mypage)
  before_action :authenticate_user!, only: %i(edit update destroy list mypage)

  # 유저 목록 보기
  def index
    @users = User.all
    render json: @users, status: :ok, scope: {params: create_params}
  end

  # 유저 마이페이지
  def show
    render json: @user, status: :ok, scope: {params: create_params}
  end

  # 유저 생성 POST sign_up
  def create
    @user = User.new user_params
    @user.normal!
    redirect_to users_sign_in_path, notice: "회원가입 완료"
  end

  def update
    @user.update! user_params
    render json: @user, status: :ok, scope: {params: create_params}
  end

  # 회원 탈퇴
  def destroy
  end

  def mypage
    render json: @user, status: :ok, scope: {params: create_params}
  end

  def list
    if params[:post_type] == "provide"
      @posts = current_user.posts.provide
      render json: {posts: @posts}, status: :ok, scope: {params: create_params}
    elsif params[:post_type] == "ask"
      @posts = current_user.posts.ask
      render json: {posts: @posts}, status: :ok, scope: {params: create_params}
    else
      render json: {error: "서비스 타입을 지정해주세요."}, status: :not_found
    end
  end

  private

  def user_params
    params.require(:user).permit(User::USER_COLUMNS)
  end

  def load_user
    begin
      @user = User.find(params[:id])
    rescue => e
      render json: {error: "없는 유저입니다."}, status: :bad_request
    end
  end
end
