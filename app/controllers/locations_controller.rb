class LocationsController < ApplicationController
  before_action :load_user, only: %i(certificate)
  before_action :load_location, only: %i(show)
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
    begin
      @location = Location.find_by(title: params[:location_title])
      return render json: {error: "존재하지 않는 지역입니다."}, status: :not_found if @location.nil?

      @user.update!(location_id: @location.id)

      render json: {notice: "사용자의 지역이 인증되었습니다."}
    rescue => e
      render json: {error: e}, status: :bad_request
    end
  end

  private
  def load_user
    begin
      @user = User.find(params[:user_id])
    rescue => e
      render json: {error: "존재하지 않는 유저입니다."}, status: :bad_request
    end
  end

  def load_location
    begin
      @location = Location.find(params[:id])
    rescue => e
      render json: {error: "존재하지 않는 지역입니다."}, status: :bad_request
    end
  end
end
