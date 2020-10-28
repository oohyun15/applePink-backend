class AddColToMessage < ActiveRecord::Migration[6.0]
  def change
    add_column :messages, :is_checked, :integer, default: 1
  end
end
