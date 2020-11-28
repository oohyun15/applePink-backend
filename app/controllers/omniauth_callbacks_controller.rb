class OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def kakao
    auth_login("kakao")
  end

  def apple
    auth_login("apple")
  end

  def after_sign_in_path_for(resource)
    auth = request.env['omniauth.auth']
    @identity = Identity.find_for_oauth(auth)
    if current_user.persisted?
      root_path
    else
        root_path
    end
  end

  private
  def auth_login(provider)
    sns_login = SnsLogin.new(request.env["omniauth.auth"], current_user)
    @user = sns_login.find_user_oauth

    if @user.persisted?
      # render json: { token: payload(@user), nickname: @user.nickname }, status: :ok
      @token = payload(@user)
      render "shared/login"
    else
      Rails.logger.error "ERROR: 로그인 에러가 발생하였습니다. #{log_info}"
      render json: { error: "로그인 에러가 발생하였습니다." }, status: :not_found
    end
  end
end