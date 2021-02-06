class Group < ApplicationRecord
  has_many :user_groups, dependent: :destroy
  has_many :users, through: :user_groups

  def display_name
    self.title
  end

  def self.generate_groups
    CSV.foreach("public/SchoolEmail.csv", headers: true) do |row|
      begin
        group = School.create!(row.to_hash)
        p "School '#{group.title}' created"
      rescue => e
        p e.message
      end
    end
  
    CSV.foreach("public/FirmEmail.csv", headers: true) do |row|
      begin
        group = Firm.create!(row.to_hash)
        p "Firm '#{group.title}' created"
      rescue => e
        p e.message
      end
    end
  end
end