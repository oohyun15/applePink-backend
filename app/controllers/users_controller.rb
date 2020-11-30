class UsersController < ApplicationController
  before_action :load_user, only: %i(show update list)
  before_action :authenticate_user!, except: %i(create find reset sms_auth)
  before_action :check_email, only: %i(email_auth)

  # 유저 목록 보기
  def index
    @users = User.all
    render json: @users, status: :ok, scope: {params: create_params}
  end

  # 유저 마이페이지
  def show
    render json: @user, status: :ok, scope: {params: create_params}, user_id: current_user.id
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
      Rails.logger.error "ERROR: #{@user.errors&.first&.last} #{log_info}"
      return render json: {error: @user.errors&.first&.last}, status: :bad_request
    end
  end

  def update
    begin
      @user.update! user_params

      if push_notification("회원정보 수정이 완료되었습니다.", "회원정보 수정 완료", @user.device_list)
        Rails.logger.info "FCM device token: #{@user.device_list}"
        return render json: @user, status: :ok, scope: {params: create_params}
      
      # 토큰 등록 이후 푸시 알림이 보내지지 않은 경우
      else
        Rails.logger.error "ERROR: 푸시 알림 전송 실패(case: 0) #{log_info}"
        return render json: {message: "푸시 알림 전송 실패"}, status: :bad_request
      end
    rescue => e
      Rails.logger.error "ERROR: #{e} #{log_info}"
      return render json: {error: e}, status: :bad_request
    end
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
            return render json: {message: "정상적으로 인증되었습니다.", group_title: group.title}, status: :ok
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
      Rails.logger.error "등록되지 않은 소속의 이메일입니다. 메일 주소를 확인해 주세요. #{log_info}"
      return render json: {error: "등록되지 않은 소속의 이메일입니다. 메일 주소를 확인해 주세요."}, status: :bad_request
    end

    if EmailCertification.generate_code(email_params[:email], "group")
      return render json: {message: "소속 인증 메일을 발송했습니다. 메일을 확인해 주세요."}, status: :ok
    else
      Rails.logger.error "ERROR: 이미 등록된 메일 주소입니다. 다른 메일 주소를 입력해 주세요. #{log_info}"
      return render json: {error: "이미 등록된 메일 주소입니다. 다른 메일 주소를 입력해 주세요."}, status: :not_acceptable
    end

    Rails.logger.error "ERROR: 이메일 인증 오류 #{log_info}"
    return render json: {error: "unauthorized"}, status: :unauthorized
  end

  def sms_auth
    if sms_params[:phone].present?
      # 전화번호와 코드 둘 다 입력됐을 때
      if sms_params[:code].present?
        if sms_certification = SmsCertification.find_by(phone: sms_params[:phone])
          if sms_certification.check_code(sms_params[:code])
            return render json: {message: "정삭적으로 인증되었습니다."}, status: :ok
          else
            Rails.logger.error "ERROR: 인증번호가 틀렸습니다. 메세지를 다시 확인하세요. #{log_info}"
            return render json: {error: "인증번호가 틀렸습니다. 메세지를 다시 확인하세요."}, status: :not_acceptable
          end
        end
      else
        # 전화번호만 입력됐을 때
        SmsCertification.generate_code(sms_params[:phone])
        return render json: {message: "소속 인증 SMS을 발송했습니다. SMS을 확인해 주세요."}, status: :ok
      end

    else
      # 입력된 전화번호가 없으면 에러 발생
      Rails.logger.error "ERROR: 입력된 번호가 없습니다 #{log_info}"
      return render json: {error: "입력된 번호가 없습니다"}, status: :bad_request
    end
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
      if push_notification("로그인이 성공적으로 완료되었습니다.", "로그인 완료", [ device_info_params[:device_token] ])
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
        # 임시로 해당 유저의 디바이스 토큰 목록에 로그인한 디바이스 토큰이 없을 경우 회원가입으로 간주
        if push_notification("회원가입이 완료되었습니다.", "모두나눔 가입 완료", [ device_info_params[:device_token] ])
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

  # 키워드 알림
  def keyword
    begin
      if request.get?
        return render json: {keywords: current_user.keyword_list, count: current_user.keyword_list.count}, status: :ok
      elsif request.post?
        if current_user.keyword_list.include?(keyword_params[:keyword])
          Rails.logger.error "ERROR: 이미 등록된 키워드입니다. #{log_info}"
          return render json: {error: "이미 등록된 키워드입니다."}, status: :bad_request  
        else
          current_user.keyword_list.add(keyword_params[:keyword])
          current_user.save!
          return render json: {message: "\"#{keyword_params[:keyword]}\"(이)가 키워드 알림에 등록되었습니다."}, status: :ok
        end
      elsif request.delete?
        unless current_user.keyword_list.include?(keyword_params[:keyword])
          Rails.logger.error "ERROR: 등록되지 않은 키워드입니다. #{log_info}"
          return render json: {error: "등록되지 않은 키워드입니다"}, status: :bad_request  
        else
          current_user.keyword_list.remove(keyword_params[:keyword])
          current_user.save!
          return render json: {message: "\"#{keyword_params[:keyword]}\"(이)가 정상적으로 삭제되었습니다."}, status: :ok
        end
      else
        Rails.logger.error "ERROR: 비정상적인 접근입니다. #{log_info}"
        render json: {error: "비정상적인 접근입니다."}, status: :bad_request
      end
    rescue => e
      Rails.logger.error "ERROR: #{e} #{log_info}"
      render json: {error: e}, status: :bad_request
    end
  end

  def find
    # 찾는 정보가 이메일일 경우
    if find_params[:for] == "email"
      @users = User.where(name: user_params[:name], birthday: user_params[:birthday], number: user_params[:number])
      
      # 입력한 정보에 맞는 사용자가 있을 경우
      unless @users.empty?
        emails = []
        @users.each do |user|
          # 결과로 나온 이메일을 암호화
          email = user.email.split("@")
          len = email[0].length
          filtered_email = email[0].gsub(email[0][(len / 2 + 1)..(len - 1)], '*' * (len - len / 2 - 1)) + "@" + email[1].gsub(/[A-Za-z]/, "*")
          emails << filtered_email
        end
        return render json: {emails: emails}, status: :ok
      else
        # 정보와 일치하는 사용자가 없는 경우
        Rails.logger.error "ERROR: 입력한 정보와 일치하는 사용자 정보가 없습니다. #{log_info}"
        return render json: {error: "입력한 정보와 일치하는 사용자 정보가 없습니다."}, status: :bad_request
      end
    # 찾는 정보가 비밀번호일 경우
    elsif find_params[:for] == "password"
      # 인증 메일 발송  
      @users = User.where(name: user_params[:name], birthday: user_params[:birthday], number: user_params[:number])
      if @user = @users.find_by(email: user_params[:email])
        EmailCertification.generate_code(user_params[:email], "find")
        return render json: {message: "해당 이메일로 인증코드를 발송했습니다."}, status: :ok
      else
        Rails.logger.error "ERROR: 입력한 정보와 일치하는 사용자 정보가 없습니다. #{log_info}"
        return render json: {error: "입력한 정보와 일치하는 사용자 정보가 없습니다."}, status: :bad_request
      end
    else
      Rails.logger.error "ERROR: 이메일을 찾을 지 비밀번호를 찾을 지 정해주세요. #{log_info}"
      return render json: {error: "이메일을 찾을 지 비밀번호를 찾을 지 정해주세요."}, status: :bad_request
    end
  end

  def reset
    # 코드 인증 시
    if email_certification = EmailCertification.find_by(email: user_params[:email])
      @users = User.where(name: user_params[:name], birthday: user_params[:birthday], number: user_params[:number])
      unless @user = @users.find_by(email: user_params[:email])
        Rails.logger.error "ERROR: 입력한 정보와 일치하는 사용자 정보가 없습니다. #{log_info}"
        return render json: {error: "입력한 정보와 일치하는 사용자 정보가 없습니다."}, status: :bad_request
      end
      
      if email_certification.check_code(find_params[:code])
        unless user_params[:password].nil?
          if user_params[:password].empty?
            Rails.logger.error "ERROR: 비밀번호를 입력해주세요. #{log_info}"
            return render json: {error: "비밀번호를 입력해주세요."}, status: :bad_request
          end
          # 비밀번호 재설정
          @user.update! user_params
    
          # 이후에 다시 비밀번호 찾기를 할 수 있게 하기 위해 삭제
          email_certification.delete
          return render json: {message: "비밀번호가 변경되었습니다."}, status: :ok
        else
          return render json: {message: "정상적으로 인증되었습니다."}, status: :ok
        end
      else
        Rails.logger.error "ERROR: 인증번호가 틀렸습니다. 메일을 다시 확인해 주세요. #{log_info}"
        return render json: {error: "인증번호가 틀렸습니다. 메일을 다시 확인해 주세요."}, status: :not_acceptable
      end
    else
      Rails.logger.error "ERROR: 올바르지 않은 이메일입니다. #{log_info}"
      return render json: {error: "올바르지 않은 이메일입니다."}, status: :not_acceptable
    end          
  end

  private

  def user_params
    prms = params.require(:user).permit(User::USER_COLUMNS)
    is_heic?(prms, :image)
    return prms
  end

  def email_params
    params.require(:user).permit(:code, :email)
  end

  def sms_params
    params.require(:user).permit(:code, :phone)
  end

  def device_info_params
    { device_type: find_device_type, device_token: params[:user][:device_token] }
  end

  def keyword_params
    params.require(:user).permit(:keyword)
  end

  def find_params
    params.require(:user).permit(:for, :code)
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
