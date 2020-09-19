class CreateUserChats < ActiveRecord::Migration[6.0]
  def change
    create_table :user_chats do |t|
      t.references :user, foriegn_key: true
      t.references :chat, foriegn_key: true
      t.timestamps
    end
  end
end
