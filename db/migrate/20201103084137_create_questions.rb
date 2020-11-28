class CreateQuestions < ActiveRecord::Migration[6.0]
  def change
    create_table :questions do |t|
      t.string :title
      t.text :body
      t.string :contact
      t.string :email
      t.timestamps
    end
  end
end
