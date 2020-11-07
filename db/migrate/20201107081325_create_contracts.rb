class CreateContracts < ActiveRecord::Migration[6.0]
  def change
    create_table :contracts do |t|
      t.datetime "start_at"
      t.datetime "end_at"
      t.string "title"
      t.references :post
      t.timestamps
    end
  end
end
