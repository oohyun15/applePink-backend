ActiveAdmin.register Report do
  menu parent: "2. 서비스 관리", priority: 4, label: "#{I18n.t("activerecord.models.report")} 관리"
  
  filter :user, label: "#{I18n.t("activerecord.attributes.report.user")} 필터"
  filter :reason, as: :select, multiple: true, collection: Report.reasons.map{|type| [I18n.t("enum.report.reason.#{type[0]}"), type[1]]}, label: "#{I18n.t("activerecord.attributes.report.reason")} 필터"
  filter :detail_cont, label: "#{I18n.t("activerecord.attributes.report.detail")} 필터"

  index do
    selectable_column
    id_column
    br
    column :user
    #  column :target_type do |report| report.target_type == "User" ? User.find(report.target_id).nickname : Post.find(report.target_id).title end
    column :target
    column :reason do |report| I18n.t("enum.report.reason.#{report.reason}") end
    column :detail do |report| report.detail&.truncate(20) end
    column :created_at do |report| short_date report.created_at end
    column :updated_at do |report| short_date report.updated_at end
    actions
  end

  show do
    attributes_table do
      row :user
      row :target
      row :reason do |report| I18n.t("enum.report.reason.#{report.reason}") end
      #  row :target_type do |report| report.target_type == "User" ? User.find(report.target_id).nickname : Post.find(report.target_id).title end
      row :detail
      row :created_at do |report| short_date report.created_at end
      row :updated_at do |report| short_date report.updated_at end
    end
    panel '이미지 목록' do
      table_for collection do
          column "이미지" do |report|
            report.images.exists? ? (
              table_for "이미지" do
                report.images.each_with_index do |image, index|
                  column "첨부 이미지 #{index + 1}" do
                    image_tag(image.image_path ,class: 'admin-index-image')
                  end
                end
              end
            )
            : "없음"
          end
      end
    end
  end
end
