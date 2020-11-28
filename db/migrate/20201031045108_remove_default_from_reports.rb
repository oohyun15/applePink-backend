class RemoveDefaultFromReports < ActiveRecord::Migration[6.0]
  def change
    change_column_default :reports, :reason, nil
  end
end
