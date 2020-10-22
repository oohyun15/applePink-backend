class LocationsController < ApplicationController
  def certificate
    begin
      #location_title 파라미터로 지역 찾기 
      @location = Location.find_by(title: params[:location_title])
      
      #존재하지 않는 동네일 때
      return render json: {error: "존재하지 않는 동네입니다."}, status: :not_found if @location.nil?

      return render json: {location_id: @location.id}
    rescue => e
      render json: {error: e}, status: :bad_request
    end
  end

end
