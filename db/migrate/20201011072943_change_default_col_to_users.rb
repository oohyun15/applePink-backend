class ChangeDefaultColToUsers < ActiveRecord::Migration[6.0]
  def change
    change_column :users, :user_type, :integer, default: 0
    change_column :users, :gender, :integer, default: 0
  end
end
