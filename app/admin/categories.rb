ActiveAdmin.register Category do
  reorderable
  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
  # permit_params :title, :position
  #
  # or
  #
  # permit_params do
  #   permitted = [:title, :position]
  #   permitted << :other if params[:action] == 'create' && current_user.admin?
  #   permitted
  # end
  index as: :reorderable_table do
    br
    column :title  
    column :position  
    
    actions
  end
end
