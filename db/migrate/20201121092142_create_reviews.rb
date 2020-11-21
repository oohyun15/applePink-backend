class CreateReviews < ActiveRecord::Migration[6.0]
  def change
    create_table :reviews do |t|
      t.references :booking
      t.text :detail
      t.float :rating
      t.timestamps
    end
    
    add_column :users, :reviews_counter, :integer, default: 0
    add_column :posts, :reviews_counter, :integer, default: 0

    add_column :posts, :rating_avg, :float, default: 0
  end
end
