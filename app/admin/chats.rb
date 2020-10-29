ActiveAdmin.register Chat do
  menu parent: "2. 서비스 관리", priority: 2, label: "#{I18n.t("activerecord.models.chat")} 관리"
  filter :post, as: :select, multiple: true, collection: Post.all.map{|type| [type.title, type.id]}, label: "#{I18n.t("activerecord.models.post")} 필터"

  index do
    id_column
    column :post
    column :user_list do |chat| chat.users end
    column :message_count do |chat| "#{number_with_delimiter chat.messages.size}개" end
    column :last_message do |chat| chat.has_message ? chat.messages.last&.body&.truncate(27) : "메시지가 없습니다." end
    
    actions
  end

  show do
    attributes_table do
      row :post
      row :user_list do |chat| chat.users end
      row :message_count do |chat| "#{number_with_delimiter chat.messages.size}개" end
    end
    panel '메시지 목록' do
      paginated_collection(chat.messages.order(created_at: :desc).page(params[:page]).per(5), download_links: false) do
      table_for collection do
          column "보낸 사람" do |message| message.user.nickname end
          column "내용" do |message| message.body.present? ? message.body : "없음" end
          column "이미지" do |message|
            message.images.exists? ? (
              table_for "이미지" do
                message.images.each_with_index do |image, index|
                  column "첨부 이미지 #{index + 1}" do
                    image_tag(image.image_path ,class: 'admin-index-image')
                  end
                end
              end
            )
            : "없음"
          end
          column "보낸 시간" do |message| long_time message.created_at end
        end
      end
    end
  end
end
