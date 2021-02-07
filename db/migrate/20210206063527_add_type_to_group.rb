class AddTypeToGroup < ActiveRecord::Migration[6.0]
  def change
    add_column :groups, :type, :string
  end
end
