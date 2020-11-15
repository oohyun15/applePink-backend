class UsersController < ApplicationController
  before_action :load_user, only: %i(show edit update list)
  before_action :authenticate_user!, except: %i(create)
  before_action :check_email, only: %i(email_auth)

  # 유저 목록 보기
  def index
    @users = User.all
    render json: @users, status: :ok, scope: {params: create_params}
  end

  # 유저 마이페이지
  def show
    render json: @user, status: :ok, scope: {params: create_params}
  end

  # 유저 생성 POST sign_up
  def create
    begin
      @user = User.new user_params
      if !(params[:user][:device_token])
        Rails.logger.error "ERROR: FCM 토큰이 없습니다. #{log_info}"
        # return render json: {error: "FCM 토큰이 없습니다."}, status: :bad_request
        @user.normal!
  
      else
        @user.device_type = device_info_params[:device_type]
        @user.device_list.add(device_info_params[:device_token])
        @user.normal!
        
        if push_notification("회원가입이 완료되었습니다.", "모두나눔 가입 완료", [ device_info_params[:device_token] ])
          Rails.logger.info "FCM device token: #{device_info_params[:device_token]}"
          return render json: {message: "회원가입이 완료되었습니다."}, status: :ok
        
        # 토큰 등록 이후 푸시 알림이 보내지지 않은 경우
        else
          Rails.logger.error "ERROR: 푸시 알림 전송 실패(case: 0) #{log_info}"
          return render json: {message: "푸시 알림 전송 실패"}, status: :bad_request
        end
  
        redirect_to users_sign_in_path, notice: "회원가입 완료"
      end
    rescue => e
      Rails.logger.error "ERROR: #{e} #{log_info}"
      return render json: {error: e}, status: :bad_request
    end
  end

  def update
    @user.update! user_params
    render json: @user, status: :ok, scope: {params: create_params}
  end

  # 회원 탈퇴
  def withdrawal
    begin
      # 해당 유저의 예약 스케줄 모두 삭제
      current_user.schedules.each do |schedule|
        Delayed::Job.find_by_id(schedule.delayed_job_id)&.delete
      end

      # 게시글 삭제
      current_user.posts.each do |post|
        post.destroy!
      end

      # 유저 삭제
      current_user.destroy!

      render json: {notice: "회원 탈퇴되었습니다."}, status: :ok
    rescue => e
      Rails.logger.error "ERROR: #{e} #{log_info}"
      render json: {error: e}, status: :bad_request
    end
  end

  def mypage
    render json: current_user, status: :ok, scope: {params: create_params}
  end

  def list
    if params[:post_type] == "provide"
      @posts = @user.posts.provide
      # order: created_at desc
      @posts = @posts.order(created_at: :desc)
      render json: @posts, status: :ok, scope: {params: create_params}
    elsif params[:post_type] == "ask"
      @posts = @user.posts.ask
      # order: created_at desc
      @posts = @posts.order(created_at: :desc)
      render json: @posts, status: :ok, scope: {params: create_params}
    else
      Rails.logger.error "ERROR: 서비스 타입을 지정해주세요. #{log_info}"
      render json: {error: "서비스 타입을 지정해주세요."}, status: :not_found
    end
  end

  def email_auth
    # 이메일, 코드 2개 다 있을 경우
    if email_params[:code].present?
      if email_certification = EmailCertification.find_by(email: email_params[:email])
        
        if email_certification.check_code(email_params[:code])
          begin
            group = Group.find_by(email: @email)
            current_user.update!(group_id: group.id) 
            return render json: {message: "정상적으로 인증되었습니다."}, status: :ok
          rescue => e
            Rails.logger.error "잘못된 소속입니다. 다시 인증해주세요. #{log_info}"
            return render json: {error: "잘못된 소속입니다. 다시 인증해주세요."}, status: :not_acceptable
          end
        else
          Rails.logger.error "ERROR: 인증번호가 틀렸습니다. 메일을 다시 확인해 주세요. #{log_info}"
          return render json: {error: "인증번호가 틀렸습니다. 메일을 다시 확인해 주세요."}, status: :not_acceptable
        end
      end
    end
    # 이메일만 있을 경우
    # 이메일이 등록된 소속들의 이메일이 아닐 때
    unless Group.all.pluck(:email).include? @email
      Rails.logger.error "등록되지 않은 소속의 이메일입니다. 메일 주소를 확인해 주세요 #{log_info}"
      return render json: {error: "등록되지 않은 소속의 이메일입니다. 메일 주소를 확인해 주세요"}, status: :bad_request
    end

    if EmailCertification.generate_code(email_params[:email])
      return render json: {message: "소속 인증 메일을 발송했습니다. 메일을 확인해 주세요."}, status: :ok
    else
      Rails.logger.error "ERROR: 정상적으로 메일을 발송하지 못했습니다. 메일 주소를 확인해 주세요. #{log_info}"
      return render json: {error: "정상적으로 메일을 발송하지 못했습니다. 메일 주소를 확인해 주세요."}, status: :not_acceptable
    end

    Rails.logger.error "ERROR: 이메일 인증 오류 #{log_info}"
    return render json: {error: "unauthorized"}, status: :unauthorized
  end

  # 지역범위 수정
  def range
    unless User.location_ranges.keys.include? params[:user][:location_range]
      Rails.logger.error "ERROR: Unpermitted parameter. #{log_info}"
      return render json: {error: "Unpermitted parameter."}, status: :bad_request
    end

    begin
      current_user.send(params[:user][:location_range] + "!")
      render json: {
        result: params[:user][:location_range],
        nickname: current_user.nickname
      }, status: :ok
    rescue => e
      Rails.logger.error "ERROR: #{e} #{log_info}"
      render json: {error: e}, status: :bad_request
    end
  end

  def add_device
    # 파라미터에 디바이스 토큰이 없을 경우
    if !(params[:user][:device_token])
      Rails.logger.error "ERROR: FCM 토큰이 없습니다. #{log_info}"
      return render json: {error: "FCM 토큰이 없습니다."}, status: :bad_request
    
    # 이미 등록된 토큰일 경우 
    elsif (current_user.device_list.include?(device_info_params[:device_token]))
      if push_notification("이미 등록된 토큰입니다.", "디바이스 등록 실패", [ device_info_params[:device_token] ])
        Rails.logger.error "ERROR: 이미 등록된 토큰입니다. #{log_info}"
        return render json: {error: "이미 등록된 토큰입니다."}, status: :ok
      
        # 푸시 알림이 보내지지 않은 경우
      else
        Rails.logger.error "ERROR: 푸시 알림 전송 실패(case: 1) #{log_info}"
        return render json: {message: "푸시 알림 전송 실패"}, status: :bad_request
      end
    else
      current_user.device_type = device_info_params[:device_type]
      current_user.device_list.add(device_info_params[:device_token])
      
      # 정상적으로 토큰이 등록된 경우
      if current_user.save

        # 토큰 등록 이후 푸시 알림이 보내진 경우
        if push_notification("정상적으로 등록되었습니다.", "디바이스 등록 완료", [ device_info_params[:device_token] ])
          Rails.logger.info "FCM device token: #{device_info_params[:device_token]}"
          return render json: {message: "정상적으로 등록되었습니다."}, status: :ok
        
        # 토큰 등록 이후 푸시 알림이 보내지지 않은 경우
        else
          Rails.logger.error "ERROR: 푸시 알림 전송 실패(case: 0) #{log_info}"
          return render json: {message: "푸시 알림 전송 실패"}, status: :bad_request
        end
      
      # 토큰 저장이 되지 않았을 경우
      else
        Rails.logger.error "ERROR: 토큰 저장 실패 #{log_info}"
        return render json: {message: "토큰 저장 실패"}, status: :bad_request
      end
    end
  end

  def remove_device
    if !(params[:user][:device_token])
      Rails.logger.error "ERROR: FCM 토큰이 없습니다. #{log_info}"
      return render json: {error: "FCM 토큰이 없습니다."}, status: :bad_request
    
    # 이미 등록 토큰일 경우 
    elsif (current_user.device_list.include?(device_info_params[:device_token]))
      current_user.device_list.remove(device_info_params[:device_token])
      current_user.save!
      return render json: {message: "디바이스 연결이 성공적으로 해제되었습니다."}, status: :ok
    
    # 디바이스 목록에 존재하지 않는 경우
    else
      Rails.logger.error "ERROR: 토큰이 디바이스 목록에 없습니다. #{log_info}"
      return render json: {error: "토큰이 디바이스 목록에 없습니다."}, status: :bad_request
    end
  end

  private

  def user_params
    is_heic?(:image) ? params.require(:user).permit(User::USER_COLUMNS).merge(image: heic2png(params[:user][:image].path)) 
    : params.require(:user).permit(User::USER_COLUMNS)
  end

  def email_params
    params.require(:user).permit(:code, :email)
  end

  def device_info_params
    { device_type: find_device_type, device_token: params[:user][:device_token] }
  end

  def load_user
    begin
      @user = User.find(params[:id])
    rescue => e
      Rails.logger.error "ERROR: 없는 유저입니다. #{log_info}"
      render json: {error: "없는 유저입니다."}, status: :bad_request
    end
  end

  def find_device_type
    Rails.logger.info "USER_AGENT: #{request.user_agent}"
    case request.user_agent
    when /mac|iOS/i
      :ios
    when /android/i
      :android
    else
      :unknown
    end
  end

  def check_email
    # 올바른 이메일 형태인지 확인
    if email_params[:email].present?
      begin
        @email = email_params[:email].split("@")[1].split(".")[0]
      rescue => e
        Rails.logger.error "ERROR: 올바르지 않은 형태의 이메일입니다. #{log_info}"
        render json: {error: "올바르지 않은 형태의 이메일입니다."}, status: :bad_request
      end
    else
      Rails.logger.error "ERROR: 입력된 이메일이 없습니다. #{log_info}"
      render json: {error: "입력된 이메일이 없습니다."}, status: :bad_request
    end
  end
end
