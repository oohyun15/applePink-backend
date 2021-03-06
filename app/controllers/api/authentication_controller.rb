module Api
  class AuthenticationController < Api::ApplicationController

    def create
      # json_params = JSON.parse(request.body.read)

      # @user = User.find_by(email: json_params["user"]["email"])
      @user = User.find_by(email: auth_params[:email])
      
      # if @user&.authenticate(json_params["user"]["password"])
      if @user&.authenticate(auth_params[:password]) 
        render json: { token: payload(@user), id: @user.id, location_auth: @user.is_location_auth? ? @user.location&.title : nil }, status: :ok
      else
        Rails.logger.error "ERROR: 이메일 또는 패스워드를 확인해주세요. #{log_info}"
        render json: { error: "이메일 또는 패스워드를 확인해주세요.", code: 3 }, status: :unauthorized
      end
    end

    ## Response으로서 보여줄 json 내용 생성 및 JWT Token 생성

    private

    def auth_params
      params.require(:user).permit(:email, :password)
    end
  end
end