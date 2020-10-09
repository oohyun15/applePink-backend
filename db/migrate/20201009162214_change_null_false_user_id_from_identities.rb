class ChangeNullFalseUserIdFromIdentities < ActiveRecord::Migration[6.0]
  def change
    change_column :identities, :user_id, :bigint, null: true
  end
end
