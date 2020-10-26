ActiveAdmin.register Post do
  menu parent: "2. 서비스 관리", priority: 1, label: "#{I18n.t("activerecord.models.post")} 관리"

  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
  # permit_params :title, :body, :status, :rent_count, :lat, :lng, :like_count, :chat_count, :user_id, :category_id, :price, :image
  #
  # or
  #
  # permit_params do
  #   permitted = [:title, :body, :status, :rent_count, :lat, :lng, :like_count, :chat_count, :user_id, :category_id, :price, :image]
  #   permitted << :other if params[:action] == 'create' && current_user.admin?
  #   permitted
  # end
  
end
