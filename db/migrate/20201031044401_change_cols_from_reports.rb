class ChangeColsFromReports < ActiveRecord::Migration[6.0]
  def change
    rename_column :reports, :report_target_id, :target_id
    rename_column :reports, :report_target_type, :target_type
    change_column :reports, :reason, :integer
    remove_column :reports, :image
  end
end
