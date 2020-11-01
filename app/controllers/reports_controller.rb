class ReportsController < ApplicationController
  before_action :authenticate_user!
  before_action :check_possible, only: %i(create)
  before_action :load_target, only: %i(create)

  def index 
    if params[:target_type].present?
      @reports = current_user.reports.where(target_type: params[:target_type].capitalize)
    else
      @reports = current_user.reports
    end

    return render json: @reports, status: :ok
  end

  def create
    #신고 대상이 자기 자신일 때
    return render json: {error: "신고 할 수 없습니다."}, status: :bad_request if current_user == @target || @target.user == current_user

    #이미 신고한 대상일 때
    return render json: {message: "이미 신고한 대상입니다."} if @report = current_user.reports.find_by(target_type: report_params[:target_type], target_id: report_params[:target_id])

    begin
      current_user.reports.create! report_params
      return render json: {message: "신고가 접수되었습니다."}, status: :ok
    rescue => e
      return render json: {error: e}, status: :bad_request
    end
  end

  private

  def report_params
    params.require(:report).permit(Report::REPORT_COLUMNS)
  end

  def load_target
    begin
      model = report_params[:target_type].capitalize
      @target = model.constantize.find(report_params[:target_id])
    rescue => e
      render json: {error: e}, status: :bad_request
    end
  end

  def check_possible
    params[:report][:target_type] = params[:report][:target_type].capitalize

    return render json: {error: "신고할 수 없는 대상입니다."}, status: :bad_request if Report::REPORT_MODELS.exclude? report_params[:target_type].capitalize
  end

end
