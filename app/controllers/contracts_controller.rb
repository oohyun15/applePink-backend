class ContractsController < ApplicationController
  before_action :authenticate_user!
  before_action :load_contract, only: %i(update)
  before_action :load_post, only: %i(create)
  before_action :load_booking, only: %i(update)
  
  def create
    @contract = @post.contract.build! contract_params
    begin
      @contract.title = @post.title
    rescue => e
      Rails.logger.debug "ERROR: #{e}"
      render json: {error: e}, status: :bad_request
    end
  end

  def update
    if contract_params[:booking_params].present?
      @contract.start_at = @booking.start_at
      @contract.end_at = @booking.end_at
    end
    @contract.update(contract_params)
    
    render json: @contract, status: :ok
  end

  private

  def contract_params
    params.require(:contract).permit(Contract::CONTRACT_COLUMNS)
  end

  def load_contract
    begin
      @contract = Contract.find(params[:id])
    rescue => e
      Rails.logger.debug "ERROR: 없는 예약입니다."
      render json: {error: "없는 예약입니다."}, status: :bad_request
    end
  end

  def load_post
    begin
      @post = Post.find(contract_params[:post_id])
    rescue => e
      Rails.logger.debug "ERROR: 없는 게시글입니다."
      render json: {error: "없는 게시글입니다."}, status: :bad_request
    end
  end

  def load_booking
    begin
      @booking = Booking.find(contract_params[:booking_id])
    rescue => e
      Rails.logger.debug "ERROR: 없는 예약입니다."
      render json: {error: "없는 예약입니다."}, status: :bad_request
    end
  end
end
