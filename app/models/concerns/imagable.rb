module Imagable
  extend ActiveSupport::Concern
  included do
    has_many :images, as: :imagable, dependent: :destroy
    accepts_nested_attributes_for :images, allow_destroy: true
  end
end
