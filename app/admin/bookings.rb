ActiveAdmin.register Booking do
  menu parent: "2. 서비스 관리", priority: 3, label: "#{I18n.t("activerecord.models.booking")} 관리"

  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
  # permit_params :user_id, :post_id, :title, :body, :price, :acceptance, :start_at, :end_at, :lent_day
  #
  # or
  #
  # permit_params do
  #   permitted = [:user_id, :post_id, :title, :body, :price, :acceptance, :start_at, :end_at, :lent_day]
  #   permitted << :other if params[:action] == 'create' && current_user.admin?
  #   permitted
  # end
  
end
