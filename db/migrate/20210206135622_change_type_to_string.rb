class ChangeTypeToString < ActiveRecord::Migration[6.0]
  def change
    change_column :groups, :type, :string
  end
end
