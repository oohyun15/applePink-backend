ActiveAdmin.register Chat do
  menu parent: "2. 서비스 관리", priority: 2, label: "#{I18n.t("activerecord.models.chat")} 관리"

  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
  # permit_params :post_id
  #
  # or
  #
  # permit_params do
  #   permitted = [:post_id]
  #   permitted << :other if params[:action] == 'create' && current_user.admin?
  #   permitted
  # end
  
end
