class Group < ApplicationRecord
  has_many :users

  def display_name
    self.title
  end

  def self.generate_groups
    CSV.foreach("public/GroupEmail.csv", headers: true) do |row|
      begin
        group = Group.create!(row.to_hash)
  
        p "Group '#{group.title}' created"
      rescue => e
        p e.message
      end
    end
  end
end
