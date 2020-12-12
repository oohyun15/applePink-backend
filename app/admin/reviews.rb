ActiveAdmin.register Review do
  menu parent: "2. 서비스 관리", priority: 4, label: "#{I18n.t("activerecord.models.review")} 관리"
  
  filter :user, label: "#{I18n.t("activerecord.attributes.review.user")} 필터"
  filter :post, label: "#{I18n.t("activerecord.attributes.review.post")} 필터"
  filter :booking, label: "#{I18n.t("activerecord.attributes.review.booking")} 필터"
  filter :body_cont, label: "#{I18n.t("activerecord.attributes.review.body")} 필터"

  index do
    selectable_column
    id_column
    br
    column :user
    column :post
    column :booking do |review| review.booking end
    column :rating
    column :body do |review| review.body&.truncate(20) end
    column :created_at do |review| short_date review.created_at end
    column :updated_at do |review| short_date review.updated_at end
    actions
  end

  show do
    attributes_table do
      row :user
      row :post
      row :booking do |review| review.booking end
      row :rating
      row :body
      row :created_at do |report| short_date report.created_at end
      row :updated_at do |report| short_date report.updated_at end
      panel '이미지 리스트' do
       table_for '이미지' do
          review.images.each_with_index do |image, index|
            column "상세이미지#{index + 1}" do
              image_tag(image.image_path ,class: 'admin-show-image')
            end
          end
        end
      end
    end
  end
end
