class Post < ApplicationRecord
  POST_COLUMNS = %i(title body price category_id)

  belongs_to :user, optional: true
  belongs_to :category, optional: true
  
end
