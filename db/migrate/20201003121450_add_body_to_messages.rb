class AddBodyToMessages < ActiveRecord::Migration[6.0]
  def change
    add_column :messages, :body, :text
  end
end
