class LocationsController < ApplicationController
  before_action :load_user, only: %i(certificate)
  before_action :load_location, only: %i(show certificate)
  before_action :authenticate_user!

  #모든 동네 목록
  def index
    @locations = Location.all
    render json: @locations, status: :ok
  end

  #특정 동네 정보 확인
  def show
    render json: @location, status: :ok
  end

  #처음 회원가입 시 지역인증
  def certificate
    @location = Location.find_by(title: params[:location][:location_title])
    
    #유저의 지역을 업데이트 함.
    @user.update!(location_id: @location.id)

    render json: {notice: "사용자의 지역이 인증되었습니다."}
  end

  private
  def load_user
    begin
      @user = User.find(params[:location][:user_id])
    rescue => e
      render json: {error: "존재하지 않는 유저입니다."}, status: :bad_request
    end
  end

  def load_location
    begin
      #url 파라미터에 id가 있을 경우에는 id로 location을 load함.
      if params[:id].present?
        @location = Location.find(params[:id])     
      else 
        #카카오 맵 API를 사용해 넘어온 법정동 이름으로 location을 load함.
        unless @location = Location.find_by(title: params[:location][:location_title])
          return render json: {error: "존재하지 않는 지역입니다."}, status: :not_found
        end
      end
    rescue => e
      render json: {error: "존재하지 않는 지역입니다."}, status: :bad_request
    end
  end
end
