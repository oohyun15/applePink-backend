class UsersController < ApplicationController
  before_action :load_user, only: %i(show edit update list)
  before_action :authenticate_user!, except: %i(index)

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
      render json: {error: e}, status: :bad_request
    end
  end

  def mypage
    render json: current_user, status: :ok, scope: {params: create_params}
  end

  def list
    if params[:post_type] == "provide"
      @posts = @user.posts.provide
      render json: {posts: @posts}, status: :ok, scope: {params: create_params}
    elsif params[:post_type] == "ask"
      @posts = @user.posts.ask
      render json: {posts: @posts}, status: :ok, scope: {params: create_params}
    else
      render json: {error: "서비스 타입을 지정해주세요."}, status: :not_found
    end
  end

  def email_auth
    # 이메일, 코드 2개 다 있을 경우
    if email_params[:code].present? && email_params[:email].present?
      if email_certification = EmailCertification.find_by(email: email_params[:email])
        
        if email_certification.check_code(email_params[:code])
          return render json: {message: "정상적으로 인증되었습니다."}, status: :ok
        else
          return render json: {error: "인증번호가 틀렸습니다. 메일을 다시 확인해 주세요."}, status: :not_acceptable
        end
      end
    # 이메일만 있을 경우
    elsif email_params[:email].present?
      if EmailCertification.generate_code(email_params[:email])
        return render json: {message: "소속 인증 메일을 발송했습니다. 메일을 확인해 주세요."}, status: :ok
      else
        return render json: {error: "정상적으로 메일을 발송하지 못했습니다. 메일 주소를 확인해 주세요."}, status: :not_acceptable
      end
    end
    return render json: {error: "unauthorized"}, status: :unauthorized
  end

  private

  def user_params
    params.require(:user).permit(User::USER_COLUMNS)
  end

  def email_params
    params.require(:user).permit(:code, :email)
  end

  def load_user
    begin
      @user = User.find(params[:id])
    rescue => e
      render json: {error: "없는 유저입니다."}, status: :bad_request
    end
  end
end
