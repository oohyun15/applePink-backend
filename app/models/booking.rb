class Booking < ApplicationRecord
  validates :start_at, presence: true

  has_one :review

  belongs_to :user
  belongs_to :post

  enum acceptance: %i(waiting accepted rejected completed rent)
end