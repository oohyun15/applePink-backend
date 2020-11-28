class CreateUserPushNotificationDevices < ActiveRecord::Migration[6.0]
  def change
    create_table :user_push_notification_devices do |t|
      t.integer :user_id
      t.integer :push_notification_device_id

      t.timestamps
    end

    add_index :user_push_notification_devices, :user_id
  end
end
