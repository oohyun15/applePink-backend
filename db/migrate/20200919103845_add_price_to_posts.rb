class AddPriceToPosts < ActiveRecord::Migration[6.0]
  def change
    add_column :posts, :price, :integer
  end
end
