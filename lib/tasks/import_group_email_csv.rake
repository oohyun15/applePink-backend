require 'csv'
namespace :import_group_email_csv do
  task :create_groups => :environment do
    CSV.foreach("public/GroupEmail.csv", :headers => true, encoding:'iso-8859-1:utf-8') do |row|
      Group.create!(row.to_hash)
    end
  end
end