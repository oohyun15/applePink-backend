class AddExpireTimeToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :expire_time, :datetime
  end
end
