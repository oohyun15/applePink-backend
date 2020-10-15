class AddCheckIdsToMessages < ActiveRecord::Migration[6.0]
  def change
    add_column :messages, :check_id, :integer, array: true, default: []
  end
end
