class AddColsToUsersAndPosts < ActiveRecord::Migration[6.0]
  def change
    add_reference :users, :location
    add_reference :posts, :location

    remove_column :users, :lat
    remove_column :users, :lng
    remove_column :posts, :lat
    remove_column :posts, :lng
  end
end
