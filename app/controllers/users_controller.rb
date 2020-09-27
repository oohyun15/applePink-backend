class UsersController < ApplicationController
  before_action :load_user, only: %i(show edit update destroy)
  before_action :authenticate_user!, only: %i(edit update destroy)

  # 유저 목록 보기
  def index
    @users = User.all
    render json: @users, status: :ok
  end

  # 유저 마이페이지
  def show
    render json: @user, status: :ok
  end

  def new
    @user = User.new
    render json: @user, status: :ok
  end

  # 유저 생성 POST sign_up
  def create
    @user = User.create! user_params
    redirect_to users_sign_in_path
  end

  def edit
    render json: current_user, status: :ok
  end

  def update
  end

  # 회원 탈퇴
  def destroy
  end

  private

  def user_params
    params.require(:user).permit(User::USER_COLUMNS)
  end

  def load_user
    @user = User.find(params[:id])
  end
end
