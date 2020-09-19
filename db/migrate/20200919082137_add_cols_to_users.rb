class AddColsToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :user_type, :integer
    add_reference :posts, :user, foreign_key: true
  end
end
