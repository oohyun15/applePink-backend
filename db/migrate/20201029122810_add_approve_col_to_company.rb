class AddApproveColToCompany < ActiveRecord::Migration[6.0]
  def change
    add_column :companies, :approve, :boolean
  end
end
