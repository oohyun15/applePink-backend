class AddCountsToModels < ActiveRecord::Migration[6.0]
  def change
    add_column :posts, :reports_count, :integer, default: 0

    add_column :posts, :likes_count, :integer, default: 0
    add_column :locations, :likes_count, :integer, default: 0
  end
end
