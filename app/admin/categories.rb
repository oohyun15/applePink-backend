ActiveAdmin.register Category do
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
