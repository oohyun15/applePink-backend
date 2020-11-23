class RemoveTitleToReviews < ActiveRecord::Migration[6.0]
  def change
    remove_column :reviews, :title
  end
end
