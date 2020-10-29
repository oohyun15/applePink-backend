class Company < ApplicationRecord
  COMPANY_COLUMNS = %i(name phone message image description location_id)

  has_one :user, dependent: :destroy
  has_many :posts, through: :user
end
