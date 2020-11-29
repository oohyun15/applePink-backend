class AddReportCountsToReview < ActiveRecord::Migration[6.0]
  def change
    add_column :reviews, :reports_count, :integer, default: 0
  end
end
