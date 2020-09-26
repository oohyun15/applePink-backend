class UsersController < ApplicationController
  before_action :load_user, only: %i(show edit update destroy)

  # 로그인 페이지
  def log_in
  end

  def sign_in
    debugger
    login_params = JSON.parse(request.body.read)
    @user = User.find_by(email: login_params["email"])
    if @user&.authenticate(login_params["password"])
      render json: { token: payload(@user), username: @user.name }, status: :ok
    else
      render json: { error: "unauthorized" }, status: :unauthorized
    end
  end

  # 유저 목록 보기
  def index
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
    redirect_to user_path(@user)
  end

  def edit
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
