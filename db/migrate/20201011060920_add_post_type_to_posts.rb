class AddPostTypeToPosts < ActiveRecord::Migration[6.0]
  def change
    add_column :posts, :post_type, :integer
  end
end
