class CreateImages < ActiveRecord::Migration[6.0]
  def change
    create_table :images do |t|
      t.string :imagable_type
      t.bigint :imagable_id
      t.string :image
      t.index [:imagable_type, :imagable_id], name: "index_images_on_imagable_type_and_imagable_id"

      t.timestamps

    end
  end
end
