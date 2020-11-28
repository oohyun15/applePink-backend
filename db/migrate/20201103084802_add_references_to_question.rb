class AddReferencesToQuestion < ActiveRecord::Migration[6.0]
  def change
    add_reference :questions, :user
  end
end
