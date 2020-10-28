class CreateSchedules < ActiveRecord::Migration[6.0]
  def change
    create_table :schedules do |t|
      t.bigint :target_id
      t.string :target_type
      t.bigint :delayed_job_id
      t.references :user
      t.timestamps
    end
  end
end
