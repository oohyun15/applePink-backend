class AddProductToPosts < ActiveRecord::Migration[6.0]
  def change
    add_column :posts, :product, :string
  end
end
