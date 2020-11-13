class AddDeviceTypeToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :device_type, :integer
    drop_table :push_notification_devices
    drop_table :user_push_notification_devices

  end
end
