class AuthenticationController < ApplicationController
  # 로그인 페이지
  def new
    render json: { message: "로그인 정보를 입력해주세요."}, status: :ok
  end

  def create
    json_params = JSON.parse(request.body.read)

    @user = User.find_by(email: json_params["user"]["email"])
    if @user&.authenticate(json_params["user"]["password"])
      render json: { token: payload(@user), nickname: @user.nickname }, status: :ok
    else
      render json: { error: "unauthorized" }, status: :unauthorized
    end
  end

  private

  ## Response으로서 보여줄 json 내용 생성 및 JWT Token 생성
  def payload(user)
    ## 해당 코드 예제에서 토큰 만료기간은 '30일' 로 설정
    @token = JWT.encode({ user_id: user.id, exp: 30.days.from_now.to_i }, ENV["SECRET_KEY_BASE"])
    @tree = { :"JWT token" => @token, :userInfo => { id: user.id, email: user.email } }

    return @tree
  end
end
