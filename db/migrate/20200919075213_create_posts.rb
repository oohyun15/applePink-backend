class CreatePosts < ActiveRecord::Migration[6.0]
  def change
    create_table :posts do |t|
      t.string :title
      t.text :body
      t.integer :status
      t.integer :rent_count
      t.decimal :lat
      t.decimal :lng
      t.integer :like_count
      t.integer :chat_count
      t.timestamps
    end
  end
end
