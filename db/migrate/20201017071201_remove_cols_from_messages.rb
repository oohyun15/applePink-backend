class RemoveColsFromMessages < ActiveRecord::Migration[6.0]
  def change
    remove_column :messages, :is_checked
  end
end
