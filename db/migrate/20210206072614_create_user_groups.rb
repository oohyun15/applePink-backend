class CreateUserGroups < ActiveRecord::Migration[6.0]
  def change
    create_table :user_groups do |t|
      t.references :user, foriegn_key: true
      t.references :group, foriegn_key: true
      t.timestamps
    end
    remove_column :users, :group_id
  end
end
