class AddColsToPostsAndBookings < ActiveRecord::Migration[6.0]
  def change
    add_column :posts, :contract, :text
    add_column :bookings, :contract, :text
  end
end
