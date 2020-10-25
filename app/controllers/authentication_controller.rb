class AuthenticationController < ApplicationController

  # 로그인 페이지
  def new
    render json: { message: "로그인 정보를 입력해주세요."}, status: :ok
  end

  def create
    # json_params = JSON.parse(request.body.read)

    # @user = User.find_by(email: json_params["user"]["email"])
    @user = User.find_by(email: auth_params[:email])
    
    # if @user&.authenticate(json_params["user"]["password"])
    if @user&.authenticate(auth_params[:password]) 
      render json: { token: payload(@user), nickname: @user.nickname, id: @user.id }, status: :ok
    else
      render json: { error: "unauthorized" }, status: :unauthorized
    end
  end

  ## Response으로서 보여줄 json 내용 생성 및 JWT Token 생성

  private

  def auth_params
    params.require(:user).permit(:email, :password)
  end
end
