class AddColToChat < ActiveRecord::Migration[6.0]
  def change
    add_column :chats, :has_message, :boolean
  end
end
