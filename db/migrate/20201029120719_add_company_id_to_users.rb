class AddCompanyIdToUsers < ActiveRecord::Migration[6.0]
  def change
    add_reference :users, :company
  end
end
