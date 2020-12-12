ActiveAdmin.register Question do
  menu parent: "2. 서비스 관리", priority: 6, label: "#{I18n.t("activerecord.models.question")} 관리"
  
  filter :user, label: "#{I18n.t("attributes.user")} 필터"
  filter :title_cont, label: "#{I18n.t("attributes.title")} 필터"
  filter :body_cont, label: "#{I18n.t("attributes.body")} 필터"
  filter :contact_cont, label: "#{I18n.t("activerecord.attributes.question.contact")} 필터"
  filter :email_cont, label: "#{I18n.t("attributes.email")} 필터"

  index do
    selectable_column
    id_column
    br
    column :user
    column :title
    column :body do |question| question.body&.truncate(20) end
    column :contact
    column :email
    column :created_at do |question| short_date question.created_at end
    column :updated_at do |question| short_date question.updated_at end
    actions
  end
end
