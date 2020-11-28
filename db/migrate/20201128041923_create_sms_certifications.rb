class CreateSmsCertifications < ActiveRecord::Migration[6.0]
  def change
    create_table :sms_certifications do |t|
      t.string :phone
      t.string :code
      t.datetime :confirmed_at
      t.timestamps
    end
  end
end
