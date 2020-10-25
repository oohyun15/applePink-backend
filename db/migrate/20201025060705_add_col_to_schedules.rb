class AddColToSchedules < ActiveRecord::Migration[6.0]
  def change
    add_column :schedules, :delayed_job_type, :string
  end
end
