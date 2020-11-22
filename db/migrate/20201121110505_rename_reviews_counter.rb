class RenameReviewsCounter < ActiveRecord::Migration[6.0]
  def change
    rename_column :users, :reviews_counter, :reviews_count
    rename_column :posts, :reviews_counter, :reviews_count
  end
end
