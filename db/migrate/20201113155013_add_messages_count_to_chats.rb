class AddMessagesCountToChats < ActiveRecord::Migration[6.0]
  def change
    add_column :chats, :messages_count, :bigint, default: 0
  end
end
