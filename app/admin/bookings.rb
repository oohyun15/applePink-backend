ActiveAdmin.register Booking do
  menu parent: "2. 서비스 관리", priority: 3, label: "#{I18n.t("activerecord.models.booking")} 관리"

  filter :user, label: "#{I18n.t("activerecord.attributes.booking.user")} 필터"
  filter :price, label: "#{I18n.t("activerecord.attributes.booking.price")} 필터"

  index do
    selectable_column
    id_column
    br
    
    column :post
    column :user do |booking| booking.user end
    column :provider do |booking| booking.post.user end
    column :lent_day do |booking| "#{number_with_delimiter booking.lent_day}일" end
    column :price do |booking| money booking.price end
    column :start_at do |booking| short_date booking&.start_at end
    column :end_at do |booking| short_date booking&.end_at end
    tag_column :acceptance
    actions
  end

end
