class ApisController < ApplicationController
  # API Controller 액션에 방문 전, application Controller의 jwt_athenticate_request! 메소드 실행
  before_action :jwt_authenticate_request!
  
  def test
    @dataJson = { message: "[Test] Token 인증 되었습니다!", user: current_user }
    render json: @dataJson, except: %i(id created_at updated_at)
  end
end
