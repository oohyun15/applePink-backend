class CreateEmailCertifications < ActiveRecord::Migration[6.0]
  def change
    create_table :email_certifications do |t|
      t.string :email
      t.string :code
      t.datetime :confirmed_at
      t.timestamps
    end
  end
end
