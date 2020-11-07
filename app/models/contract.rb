class Contract < ApplicationRecord

  CONTRACT_COLUMNS = %i(start_at end_at post_id booking_id)

  belongs_to :post

  has_many :terms, dependent: :destroy

  accepts_nested_attributes_for :terms, allow_destroy: true
end
