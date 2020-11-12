class Group < ApplicationRecord
  has_many :users

  def display_name
    self.title
  end
end
