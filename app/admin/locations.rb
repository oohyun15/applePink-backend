ActiveAdmin.register Location do
  menu parent: "3. 사이트 관리", priority: 1, label: "#{I18n.t("activerecord.models.location")} 관리"

  config.sort_order = 'position_asc'
  
  index do
    br
    column :position  
    column :title  
    column :likes_count do |location| "#{number_with_delimiter location.likes_count}개" end
    column :location_near do |location| Location.where(position: location.location_near) end
    column :location_normal do |location| Location.where(position: location.location_normal) end
    column :location_far do |location| Location.where(position: location.location_far) end
    actions
  end
end
