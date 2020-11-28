class CreatePushNotificationDevices < ActiveRecord::Migration[6.0]
  def change
    create_table :push_notification_devices do |t|
      t.integer :device_type
      t.string :device_token

      t.timestamps
    end
    add_index :push_notification_devices, :device_type
  end
end
