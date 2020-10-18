ActiveAdmin.register Location do
  config.sort_order = 'position_asc'
  
  index do
    br
    column :position  
    column :title  
    column :lat  
    column :lng  
    column :location_near do |location| Location.where(position: location.location_near) end
    column :location_normal do |location| Location.where(position: location.location_normal) end
    column :location_far do |location| Location.where(position: location.location_far) end
    actions
  end
end
