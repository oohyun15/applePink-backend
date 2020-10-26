ActiveAdmin.register Chat do
  menu parent: "2. 서비스 관리", priority: 2, label: "#{I18n.t("activerecord.models.chat")} 관리"
  filter :post, as: :select, multiple: true, collection: Post.all.map{|type| [type.title, type.id]}, label: "#{I18n.t("activerecord.models.post")} 필터"

  index do
    id_column
    column :post
    column :user_list do |chat| chat.users end
    column :message_count do |chat| "#{number_with_delimiter chat.messages.size}개" end
    column :last_message do |chat| chat.has_message ? chat.messages.last&.body&.truncate(27) : "메시지가 없습니다." end
  end
end
