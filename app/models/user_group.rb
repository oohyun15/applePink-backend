class UserGroup < ApplicationRecord
  belongs_to :user
  belongs_to :group, counter_cache: true
end
