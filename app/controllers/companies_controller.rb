class CompaniesController < ApplicationController
  before_action :authenticate_user!, except: %i(confirm)
  before_action :authenticate_admin_user!, only: %i(confirm)
  before_action :load_company, only: %i(show destroy confirm)
  before_action :check_owner, only: %i(destroy)

  def create
    if current_user.company.present?
      if current_user.company&.approve
        return render json: {message: "#{current_user.nickname}님은 광고주입니다."}, status: :ok
      else
        return render json: {message: "#{current_user.nickname}님은 현재 승인대기 상태입니다."}, status: :ok
      end
    else
      begin
        @company = current_user.build_company company_params
        @company.update!(approve: false)
        return render json: {message: "광고주 신청이 완료돠었습니다."}, status: :ok
      rescue => e
        render json: {error: e}, status: :bad_request
      end
    end
  end

  def destroy
    begin
      @company.destroy!
      return render json: {message: "광고주 신청이 취소되었습니다."}, status: :ok
    rescue => e
      Rails.logger.debug "ERROR: #{e}"
      render json: {error: e}, status: :bad_request
    end
  end

  # 관리자 액션
  def confirm
    begin
      if params[:approve] == "true"
        @company.update!(approve: true)
        @company.user.company!
      elsif params[:approve] == "false"
        @company.update!(approve: false)
        @company.user.normal!
      end
    rescue
      return false
    end
    redirect_to request.referrer
  end

  private

  def load_company
    @company = Company.find(params[:id])
  end

  def check_owner
    if @company.user != current_user
      Rails.logger.debug "ERROR: 광고주 관련 권한이 없습니다."
      render json: { error: "unauthorized" }, status: :unauthorized
    end
  end
  
  def company_params
    params.require(:company).permit(Company::COMPANY_COLUMNS)
  end
end
