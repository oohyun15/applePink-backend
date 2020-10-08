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
    @image = Image.find_by(id: params[:id])
    redirect_to root_path unless @image
  end

end
