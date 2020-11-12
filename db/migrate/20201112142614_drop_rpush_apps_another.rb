class DropRpushAppsAnother < ActiveRecord::Migration[6.0]
  def change
    drop_table :rpush_feedback
    drop_table :rpush_notifications
  end
end
