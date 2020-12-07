class AddEffectiveDateToPages < ActiveRecord::Migration[6.0]
  def change
    add_column :pages, :effective_date, :datetime
  end
end
