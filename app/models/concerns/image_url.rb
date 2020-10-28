module ImageUrl
  extend ActiveSupport::Concern

  included do
    mount_uploader :image, ImageUploader if Rails.env.development?
    mount_uploader :image, S3Uploader if Rails.env.production?
  end

  def image_path size = :square
    image? ? image.url(size) : '/image/default.png'
  end

  def upload_image_path size = :square
    image? ? image.url(size) : '/image/default.png'
  end
end
