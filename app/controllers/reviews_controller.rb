class ReviewsController < ApplicationController
  before_action :authenticate_user!
  before_action :load_booking, only: %i(create destroy)

  def create

  end

  def destroy

  end

  private

  def load_booking
    begin
      @booking = Booking.find(params[:id])
    rescue => e
      Rails.logger.error "ERROR: 없는 예약입니다. #{log_info}"
      render json: {error: "없는 예약입니다."}, status: :bad_request
    end
  end
end
