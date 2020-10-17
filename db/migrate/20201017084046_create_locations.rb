class CreateLocations < ActiveRecord::Migration[6.0]
  def change
    create_table :locations do |t|
      t.string :title
      t.decimal :lat
      t.decimal :lng
      t.integer :position
      t.integer :location_near, default: [], array: true
      t.integer :location_normal, default: [], array: true
      t.integer :location_far, default: [], array: true
      t.timestamps
    end
  end
end
