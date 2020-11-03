class ImagesController < ApplicationController
  before_action :load_image, only: %i(destroy)

  def create
    @image = Image.create! image_params
  end

  def destroy
    @image.destroy!
  end

  private

  def image_params
    params.require(:image).permit(:id, :image, :imagable_type, :imagable_id)
  end

  def load_image
    begin
    @image = Image.find_by(id: params[:id])
    rescue => e
      Rails.logger.debug "ERROR: 없는 이미지입니다."
      render json: {error: "없는 이미지입니다."}, status: :bad_request
    end
  end

end
