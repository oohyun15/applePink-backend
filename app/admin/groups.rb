ActiveAdmin.register Group do
  menu parent: "3. 사이트 관리", priority: 3, label: "#{I18n.t("activerecord.models.group")} 관리"
  
  filter :title_cont, label: "#{I18n.t("activerecord.attributes.group.title")} 필터"
  filter :email_cont, label: "#{I18n.t("activerecord.attributes.group.email")} 필터"

  index do
    selectable_column
    id_column
    br
    column :position  
    column :title  
    column :email
    column :users_count do |group| "#{number_with_delimiter group.user_groups.size}명" end
    actions
  end
end
