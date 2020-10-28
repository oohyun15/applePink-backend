class DeleteColsToSchedules < ActiveRecord::Migration[6.0]
  def change
    remove_column :schedules, :target_id
    remove_column :schedules, :target_type
  end
end
