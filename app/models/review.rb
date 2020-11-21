class Review < ApplicationRecord
  belongs_to :booking

  delegate :user, :to => :booking, :allow_nil => true
  delegate :post, :to => :booking, :allow_nil => true
end
