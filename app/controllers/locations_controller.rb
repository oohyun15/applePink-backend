class LocationsController < ApplicationController
  #처음 회원가입 시 지역인증
  def update
    byebug
    begin
      #location_title 파라미터로 지역 찾기 
      @location = Location.find_by(title: params[:location_title])
      
      #존재하지 않는 동네일 때
      return render json: {error: "존재하지 않는 동네입니다."}, status: :not_found if @location.nil?

      @user = User.find_by(id: params[:id])
      #존재하지 않는 사용자일 때
      return render json: {error: "존재하지 않는 사용자입니다."}, status: :not_found if @user.nil?

      @user.update!(location_id: @location.id)

      return render json: {notice: "사용자의 지역이 인증되었습니다."}
    rescue => e
      render json: {error: e}, status: :bad_request
    end
  end

end
