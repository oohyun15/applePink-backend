class AddColumnsToCompanies < ActiveRecord::Migration[6.0]
  def change
    add_column :companies, :title, :string
    add_column :companies, :business_registration, :string
    add_column :companies, :business_address, :string
    add_column :companies, :biz_type, :string
    add_column :companies, :category, :string
  end
end
