class ReportsController < ApplicationController
  before_action :authenticate_user!
  before_action :check_possible, only: %i(create)
  before_action :load_target, only: %i(create)
  before_action :load_user, only: %i(index)

  def index 
    if params[:report_target_type].present?
      @reports = @user.reports.where(report_target_type: params[:report_target_type].capitalize)
    else
      @reports = @user.reports
    end

    return render json: @reports, status: :ok
  end

  def report
    #신고 대상이 자기 자신일 때
    return render json: {error: "신고 할 수 없습니다."}, status: :bad_request if current_user == @target

    #이미 신고한 대상일 때
    if @report = current_user.reports.find_by(report_target_type: report_params[:report_target_type], report_target_id: report_params[:report_target_id])
      return render json: {message: "이미 신고한 대상입니다."}
    end

    current_user.reports.create! report_params

    return render json: {message: "신고가 접수되었습니다."}, status: :ok
  end

  private

  def report_params
    params.require(:report).permit(Report::REPORT_COLUMNS)
  end

  def load_user
    begin
      @user = User.find(params[:user_id])
    rescue => e
      render json: {error: "없는 유저입니다."}, status: :bad_request
    end
  end

  def load_target
    begin
      model = report_params[:report_target_type].capitalize
      @target = model.constantize.find(report_params[:report_target_id])
    rescue => e
      render json: {error: e}, status: :bad_request
    end
  end

  def check_possible
    params[:report][:report_target_type] = params[:report][:report_target_type].capitalize

    return render json: {error: "신고할 수 없는 대상입니다."}, status: :bad_request if Report::REPORT_MODELS.exclude? report_params[:report_target_type].capitalize
  end

end
