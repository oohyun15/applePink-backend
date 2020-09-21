class AddPostIdToChats < ActiveRecord::Migration[6.0]
  def change
    add_reference :chats, :post, foreign_key: true
  end
end
