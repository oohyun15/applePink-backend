class CreateBookings < ActiveRecord::Migration[6.0]
  def change
    create_table :bookings do |t|
      t.references :user, foriegn_key: true
      t.references :post, foriegn_key: true
      t.string :title
      t.text :body
      t.integer :price
      t.integer :acceptance, default: 0
      t.datetime :start_at
      t.datetime :end_at
      t.timestamps
    end
  end
end
