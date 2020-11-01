class LocationsController < ApplicationController
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
    # 1주일 이후 지역 인증 초기화
    expire_time = 1.week.from_now

    # 유저의 지역을 업데이트 함.
    current_user.update!(location_id: @location.position, expire_time: expire_time)
    
    # @post.delayed_job_id를 통해 기존 job 제거
    schedule = current_user.schedules.find_or_initialize_by(delayed_job_type: "Location")
  
    # 기존 schedule이 있을 경우 제거
    Delayed::Job.find_by_id(schedule.delayed_job_id)&.delete unless schedule.new_record?

    delayed_job = current_user.delay(run_at: expire_time).update!(location_id: nil, expire_time: nil)

    # job id 업데이트
    schedule.update!(delayed_job_id: delayed_job.id)

    render json: {notice: "사용자의 지역이 인증되었습니다. #{expire_time.strftime('%Y년 %m월 %d일')} 후에 인증이 만료됩니다."}
  end

  private

  def load_location
    begin
      #url 파라미터에 id가 있을 경우에는 id로 location을 load함.
      if params[:id].present?
        @location = Location.find(params[:id])     
      else 
        #카카오 맵 API를 사용해 넘어온 법정동 이름으로 location을 load함.
        unless @location = Location.find_by(title: params[:location][:title])
          return render json: {error: "존재하지 않는 지역입니다."}, status: :not_found
        end
      end
    rescue => e
      render json: {error: "존재하지 않는 지역입니다."}, status: :bad_request
    end
  end
end
