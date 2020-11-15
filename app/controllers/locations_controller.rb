class LocationsController < ApplicationController
  before_action :load_location, only: %i(show display certificate)
  before_action :authenticate_user!

  #모든 동네 목록
  def index
    @locations = Location.all
    render json: @locations, status: :ok, scope: {params: create_params}
  end

  #특정 동네 정보 확인
  def show
    render json: @location, status: :ok, scope: {params: create_params}
  end

  #def display
  #  if current_user.location.nil?
  #    Rails.logger.error "ERROR: 지역 인증이 만료되었습니다. 지역 인증을 다시 실행해주세요. #{log_info}"
  #    return render json: {error: "지역 인증이 만료되었습니다. 지역 인증을 다시 실행해주세요."}, status: :bad_request
  #  end
    
  #  return render json: @location, scope: {params: create_params}
  #end

  #처음 회원가입 시 지역인증
  def certificate
    # 1주일 이후 지역 인증 초기화
    expire_time = 1.week.from_now

    # 유저의 지역을 업데이트 함.
    current_user.update!(location_id: @location.position, expire_time: expire_time)

    current_user.posts.each do |post| post.update!(location_id: @location.position) end
    
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
    
    #url 파라미터에 id가 있을 경우에는 id로 location을 load함.
    if params[:id].present?
      begin
        @location = Location.find(params[:id])   
      rescue => e
        Rails.logger.error "ERROR: 존재하지 않는 지역입니다. #{log_info}"
        render json: {error: "존재하지 않는 지역입니다."}, status: :bad_request
      end
    elsif params[:location][:title].present?
      #카카오 맵 API를 사용해 넘어온 법정동 이름으로 location을 load함.
      #unless @location = Location.find_by(title: params[:location][:title])
      #  Rails.logger.error "ERROR: 존재하지 않는 지역입니다. #{log_info}"
      #  return render json: {error: "존재하지 않는 지역입니다."}, status: :not_found
      #end

      # 법정동 이름으로 location을 load하거나 등록된 location이 없으면 새로운 location을 생성함.
      begin
        @location = Location.find_or_create_by!(title: params[:location][:title])
      rescue => e
        Rails.logger.error "ERROR: #{e} #{log_info}"
        render json: {error: e}, status: :bad_request
      end
    else
      Rails.logger.error "ERROR: 비정상적인 요청 #{log_info}"
      render json: {error: "비정상적인 요청"}, status: :bad_request
    end
  end
end
