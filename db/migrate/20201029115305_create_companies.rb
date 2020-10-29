class CreateCompanies < ActiveRecord::Migration[6.0]
  def change
    create_table :companies do |t|
      t.string :name
      t.string :phone
      t.string :message
      t.string :image
      t.text :description
      t.references :location
      t.timestamps
    end
  end
end
