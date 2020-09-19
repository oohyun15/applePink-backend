class Post < ApplicationRecord
  POST_COLUMNS = %i(title body price)

  belongs_to :user, optional: true
  belongs_to :category, optional: true
  
end
