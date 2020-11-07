class AddBodyToContracts < ActiveRecord::Migration[6.0]
  def change
    add_column :contracts, :body, :text
  end
end
