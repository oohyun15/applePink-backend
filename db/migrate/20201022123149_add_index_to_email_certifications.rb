class AddIndexToEmailCertifications < ActiveRecord::Migration[6.0]
  def change
    add_index :email_certifications, :email
  end
end
