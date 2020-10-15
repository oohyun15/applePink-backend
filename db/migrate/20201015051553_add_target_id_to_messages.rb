class AddTargetIdToMessages < ActiveRecord::Migration[6.0]
  def change
    add_column :messages, :target_id, :bigint
  end
end
