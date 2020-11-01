class CreateReports < ActiveRecord::Migration[6.0]
  def change
    create_table :reports do |t|
      t.bigint :report_target_id
      t.string :report_target_type
      t.references :user
      t.integer :reason, default: 0
      t.text :detail 
      t.timestamps
    end
  end
end
