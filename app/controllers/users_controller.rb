class UsersController < ApplicationController
  before_action :load_user, only: %i(show edit update destroy)
  before_action :authenticate_user!, only: %i(edit update destroy)

  # 유저 목록 보기
  def index
    @users = User.all
    render json: @users, status: :ok, scope: {params: create_params}
  end

  # 유저 마이페이지
  def show
    render json: @user, status: :ok
  end

  # 유저 생성 POST sign_up
  def create
    @user = User.new user_params
    @user.normal!
    redirect_to users_sign_in_path, notice: "회원가입 완료"
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
    begin
      @user = User.find(params[:id])
    rescue => e
      render json: {error: "없는 유저입니다."}, status: :bad_request
    end
  end
end
