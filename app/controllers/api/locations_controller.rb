module Api
  class LocationsController < Api::ApplicationController
    before_action :load_location, only: %i(show display certificate)
    before_action :authenticate_user!

    #모든 동네 목록
    def index
      @locations = Location.all
      render json: @locations, status: :ok, scope: {params: create_params}, user_id: current_user.id
    end

    #특정 동네 정보 확인
    def show
      render json: @location, status: :ok, scope: {params: create_params}, user_id: current_user.id
    end

    def display
      return render json: @location, status: :ok, scope: {params: create_params}, user_id: current_user.id
    end

    #처음 회원가입 시 지역인증
    def certificate
      # 1주일 이후 지역 인증 초기화
      expire_time = 1.week.from_now

      # 유저의 지역을 업데이트 함.
      current_user.update!(location_id: @location.position, location_range: params[:location][:range].to_i, expire_time: expire_time)

      current_user.posts.each do |post| post.update!(location_id: @location.position) end
      
      # @post.delayed_job_id를 통해 기존 job 제거
      schedule = current_user.schedules.find_or_initialize_by(delayed_job_type: "Location")
    
      # 기존 schedule이 있을 경우 제거
      Delayed::Job.find_by_id(schedule.delayed_job_id)&.delete unless schedule.new_record?

      delayed_job = current_user.delay(run_at: expire_time).update!(location_id: nil, location_range: :location_alone, expire_time: nil)

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
      elsif params[:title].present?
        begin
          if (@location = Location.find_by(title: params[:title])).nil?
            # 심사 전 임시로 지역락 해제
            # render json: {error: "#{params[:title]}은(는) 지원하지 않는 지역입니다."}, status: :bad_request
            # legacy (21.01.23) 찾는 지역이 없을 시 새로 생김
            position = Location.last.position + 1
            @location = Location.create!(title: params[:title], position: position,location_near: [position], 
                                        location_normal: [position], location_far: [position])
          end
        rescue => e
          Rails.logger.error "#{e} #{log_info}"
          render json: {error: e}, status: :bad_request
        end
      elsif params[:location][:title].present?
        #카카오 맵 API를 사용해 넘어온 법정동 이름으로 location을 load함.
        #unless @location = Location.find_by(title: params[:location][:title])
        #  Rails.logger.error "ERROR: 존재하지 않는 지역입니다. #{log_info}"
        #  return render json: {error: "존재하지 않는 지역입니다."}, status: :not_found
        #end

        # 법정동 이름으로 location을 load함.  
        @location = Location.find_by(title: params[:location][:title])

        if @location.nil?
          Rails.logger.error "존재하지 않는 지역입니다. #{log_info}"
          render json: {error: "존재하지 않는 지역입니다."}, status: :not_found
        end
      else
        Rails.logger.error "ERROR: 비정상적인 요청 #{log_info}"
        render json: {error: "비정상적인 요청"}, status: :bad_request
      end
    end
  end
end