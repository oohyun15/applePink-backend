class AddIndexToSmsCertifications < ActiveRecord::Migration[6.0]
  def change
    add_index :sms_certifications, :phone
  end
end
