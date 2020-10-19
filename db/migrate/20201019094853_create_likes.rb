class CreateLikes < ActiveRecord::Migration[6.0]
  def change
    create_table :likes do |t|
      t.bigint :target_id
      t.string :target_type
      t.references :user
      t.timestamps
    end
  end
end
