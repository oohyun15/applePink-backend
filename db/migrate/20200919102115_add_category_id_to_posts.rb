class AddCategoryIdToPosts < ActiveRecord::Migration[6.0]
  def change
    add_reference :posts, :category
    add_reference :users, :group
  end
end
