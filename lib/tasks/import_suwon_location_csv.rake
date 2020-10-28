require 'csv'
namespace :import_suwon_location_csv do
  task :create_locations => :environment do
    CSV.foreach("public/SuwonLocation.csv", :headers => true, encoding:'iso-8859-1:utf-8') do |row|
      Location.create!(row.to_hash)
    end
  end
end