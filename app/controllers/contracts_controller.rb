class ContractsController < ApplicationController
  before_action :authenticate_user!
  before_action :load_contract, only: %i(show update)
  before_action :load_post, only: %i(create)
  before_action :load_booking, only: %i(update)
  
  def show
    return render json: @contract, status: :ok
  end

  def create
    if @post.contract.present?
      return render json: {error: "이미 계약서가 존재합니다."}
    end

    @contract = @post.build_contract contract_params
    begin
      @contract.title = @post.title
      @contract.save
      return render json: @contract, status: :ok
    rescue => e
      Rails.logger.debug "ERROR: #{e}"
      render json: {error: e}, status: :bad_request
    end
  end

  def update
    if booking_param[:booking_id].present?
      @contract.start_at = @booking.start_at
      @contract.end_at = @booking.end_at
      @contract.price = @booking.price
    end

    @contract.update(contract_params)
    
    render json: @contract, status: :ok
  end

  private

  def contract_params
    params.require(:contract).permit(Contract::CONTRACT_COLUMNS)
  end

  def booking_param
    params.require(:contract).permit(:booking_id)
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
    if booking_param[:booking_id].present?
      begin
        @booking = Booking.find(booking_param[:booking_id])
      rescue => e
        Rails.logger.debug "ERROR: 없는 예약입니다."
        render json: {error: "없는 예약입니다."}, status: :bad_request
      end
    end
  end
end
