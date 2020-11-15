class AddColsToBookings < ActiveRecord::Migration[6.0]
  def change
    add_column :bookings, :provider_sign_datetime, :datetime
    add_column :bookings, :consumer_sign_datetime, :datetime
  end
end
