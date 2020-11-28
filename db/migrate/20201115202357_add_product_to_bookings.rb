class AddProductToBookings < ActiveRecord::Migration[6.0]
  def change
    add_column :bookings, :product, :string
  end
end
