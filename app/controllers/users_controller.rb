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
    @user = User.new user_params
    @user.normal!
    @user.add_device_info(device_info_params)
    redirect_to users_sign_in_path, notice: "회원가입 완료"
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
      Rails.logger.debug "ERROR: #{e}"
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
      Rails.logger.debug "ERROR: 서비스 타입을 지정해주세요."
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
            Rails.logger.debug "잘못된 소속입니다. 다시 인증해주세요."
            return render json: {error: "잘못된 소속입니다. 다시 인증해주세요."}, status: :not_acceptable
          end
        else
          Rails.logger.debug "ERROR: 인증번호가 틀렸습니다. 메일을 다시 확인해 주세요."
          return render json: {error: "인증번호가 틀렸습니다. 메일을 다시 확인해 주세요."}, status: :not_acceptable
        end
      end
    end
    # 이메일만 있을 경우
    # 이메일이 등록된 소속들의 이메일이 아닐 때
    unless Group.all.pluck(:email).include? @email
      Rails.logger.debug "등록되지 않은 소속의 이메일입니다. 메일 주소를 확인해 주세요"
      return render json: {error: "등록되지 않은 소속의 이메일입니다. 메일 주소를 확인해 주세요"}, status: :bad_request
    end

    if EmailCertification.generate_code(email_params[:email])
      return render json: {message: "소속 인증 메일을 발송했습니다. 메일을 확인해 주세요."}, status: :ok
    else
      Rails.logger.debug "ERROR: 정상적으로 메일을 발송하지 못했습니다. 메일 주소를 확인해 주세요."
      return render json: {error: "정상적으로 메일을 발송하지 못했습니다. 메일 주소를 확인해 주세요."}, status: :not_acceptable
    end

    Rails.logger.debug "ERROR: 이메일 인증 오류"
    return render json: {error: "unauthorized"}, status: :unauthorized
  end

  def range
    unless User.location_ranges.keys.include? params[:user][:location_range]
      Rails.logger.debug "ERROR: Unpermitted parameter."
      return render json: {error: "Unpermitted parameter."}, status: :bad_request
    end

    begin
      current_user.send(params[:user][:location_range] + "!")
      render json: {
        result: params[:user][:location_range],
        nickname: current_user.nickname
      }, status: :ok
    rescue => e
      Rails.logger.debug "ERROR: #{e}"
      render json: {error: e}, status: :bad_request
    end
  end

  def add_device
    if current_user.add_device_info(device_info_params)
      if current_user.push_notification("정상적으로 등록되었습니다.", "모두나눔")
        return render json: {message: "정상적으로 등록되었습니다."}, status: :ok
      else
        return render json: {message: "메시지 전송 실패"}, status: :bad_request
      end
    else
      Rails.logger.debug "ERROR: Unknown device token."
      return render json: {error: "Unknown device token."}, status: :bad_request
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
      Rails.logger.debug "ERROR: 없는 유저입니다."
      render json: {error: "없는 유저입니다."}, status: :bad_request
    end
  end

  def find_device_type
    Rails.logger.debug "USER_AGENT: #{request.user_agent}"
    case request.user_agent
    when /mac|iOS/i
      :ios
    when /android/i
      :android
    else
      nil
    end
  end

  def check_email
    # 올바른 이메일 형태인지 확인
    if email_params[:email].present?
      begin
        @email = email_params[:email].split("@")[1].split(".")[0]
      rescue => e
        Rails.logger.debug "ERROR: 올바르지 않은 형태의 이메일입니다."
        render json: {error: "올바르지 않은 형태의 이메일입니다."}, status: :bad_request
      end
    else
      Rails.logger.debug "ERROR: 입력된 이메일이 없습니다."
      render json: {error: "입력된 이메일이 없습니다."}, status: :bad_request
    end
  end
end
