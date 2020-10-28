ActiveAdmin.register Category do
  menu parent: "3. 사이트 관리", priority: 2, label: "#{I18n.t("activerecord.models.category")} 관리"

  config.sort_order = 'position_asc'
  config.paginate   = false

  reorderable
  
  index as: :reorderable_table do
    br
    column :title  
    column :position  
    
    actions
  end
end
