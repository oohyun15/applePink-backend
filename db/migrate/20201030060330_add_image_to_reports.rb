class AddImageToReports < ActiveRecord::Migration[6.0]
  def change
    add_column :reports, :image, :string
  end
end
