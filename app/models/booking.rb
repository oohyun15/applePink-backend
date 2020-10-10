class Booking < ApplicationRecord
  validates :start_at, presence: true

  belongs_to :user
  belongs_to :post

  enum acceptance: %i(waiting accepted rejected completed)
end