class RenameDetailFromReviews < ActiveRecord::Migration[6.0]
  def change
    add_column :reviews, :title, :string
    rename_column :reviews, :detail, :body
  end
end
