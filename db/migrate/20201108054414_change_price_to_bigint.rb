class ChangePriceToBigint < ActiveRecord::Migration[6.0]
  def change
    change_column :posts, :price, :bigint
    change_column :bookings, :price, :bigint
  end
end
