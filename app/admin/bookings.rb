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
    column :lent_day do |booking| "#{booking.lent_day}일" end
    tag_column :acceptance
    column :start_at do |booking| booking&.start_at&.strftime('%Y년 %m월 %d일') end
    column :end_at do |booking| booking&.end_at&.strftime('%Y년 %m월 %d일') end
    actions
  end

end
