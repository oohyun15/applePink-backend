class Post < ApplicationRecord
  POST_COLUMNS = %i(title body price)

  belongs_to :user
  belongs_to :category
  
end
