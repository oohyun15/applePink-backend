class CreateUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :users do |t|
      t.string :email, index: { unique: true }
      t.string :password_digest
      t.string :nickname, index: { unique: true }
      t.integer :gender
      t.float :lat
      t.float :lng
      t.text :body

      t.timestamps
    end
  end
end
