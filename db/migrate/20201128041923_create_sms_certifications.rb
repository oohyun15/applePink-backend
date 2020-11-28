class CreateSmsCertifications < ActiveRecord::Migration[6.0]
  def change
    create_table :sms_certifications do |t|

      t.timestamps
    end
  end
end
