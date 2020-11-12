class AddCountsToGroups < ActiveRecord::Migration[6.0]
  def change
    add_column :groups, :users_count, :integer, default: 0
  end
end
