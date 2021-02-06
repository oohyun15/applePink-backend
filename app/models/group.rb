class Group < ApplicationRecord
  has_many :user_groups, dependent: :destroy
  has_many :users, through: :user_groups
  self.inheritance_column = :_type_disabled

  def display_name
    self.title
  end

  def self.subclasses
    [Firm, School]
  end

  def self.generate_groups
    CSV.foreach("public/SchoolEmail.csv", headers: true) do |row|
      begin
        group = Group::School.create!(row.to_hash)
        p "School '#{group.title}' created"
      rescue => e
        p e.message
      end
    end
  
    CSV.foreach("public/FirmEmail.csv", headers: true) do |row|
      begin
        group = Group::Firm.create!(row.to_hash)
        p "Firm '#{group.title}' created"
      rescue => e
        p e.message
      end
    end
  end
end

require_dependency "group/school"
require_dependency "group/firm"