class UpdateUserAndComapny < ActiveRecord::Migration[6.0]
  def change
    remove_reference :users, :company
    add_reference :companies, :user
  end
end
