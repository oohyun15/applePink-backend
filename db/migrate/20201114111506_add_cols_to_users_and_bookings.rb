class AddColsToUsersAndBookings < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :name, :string
    add_column :users, :birthday, :string
    add_column :users, :number, :string

    add_column :bookings, :provider_name, :string
    add_column :bookings, :consumer_name, :string
  end
end
