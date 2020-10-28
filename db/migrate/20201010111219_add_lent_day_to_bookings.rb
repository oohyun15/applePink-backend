class AddLentDayToBookings < ActiveRecord::Migration[6.0]
  def change
    add_column :bookings, :lent_day, :integer
  end
end
