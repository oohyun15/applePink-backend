ActiveAdmin.register User do
  menu parent: "1. 유저 관리", priority: 1, label: "#{I18n.t("activerecord.models.user")} 관리"
  
  filter :nickname
  filter :email
  filter :user_type, as: :select, multiple: true, collection: User.user_types.map{|type| [I18n.t("enum.user.user_type.#{type[0]}"), type[1]]}
  filter :account_type
  
  index do
    selectable_column
    id_column
    br
    column :image do |user| image_tag(user&.image_path ,class: 'admin-index-image') end
    column :nickname
    column :email
    column :location do |user| user.location.present? ? user.location : "지역인증 필요" end
    column :expiration_time do |user| user.location.present? && user.schedules.exists? ? user.schedules.find_by(delayed_job_type: "Location").updated_at.strftime('%Y년 %m월 %d일') : "지역인증 필요" end
    column :gender do |user| I18n.t("enum.user.gender.#{user.gender}") end
    tag_column :user_type do |user| user.user_type.present? ? user.user_type : "미지정" end
    column :location_range do |user| user.user_type.present? ? I18n.t("enum.user.location_range.#{user.location_range}") : "미지정" end
    column :created_at do |user| user.created_at.strftime('%Y년 %m월 %d일') end
    column :updated_at do |user| user.updated_at.strftime('%Y년 %m월 %d일') end
    tag_column :account_type do |user| user.account_type end
    actions
  end

  show do |post|
    attributes_table do
      row :image do |user| image_tag(user&.image_path ,class: 'admin-show-image') end
      row :nickname
      row :email
      row :location
      tag_row :gender
      tag_row :user_type do |user| user.user_type.present? ? user.user_type : "미지정" end
      row :location_range do |user| user.location_range.present? ? I18n.t("enum.user.location_range.#{user.location_range}") : "미지정" end
      row :created_at
      row :updated_at
      tag_row :account_type do |user| I18n.t("enum.user.account_type.#{user.account_type}") end
    end
  end

  form do |f|
    f.inputs do
      f.input :nickname
      f.input :email
      f.input :location
      f.input :gender
      f.input :image, as: :file, hint: image_tag(f.object&.image_path, class: 'admin-show-image')
      f.input :user_type, as: :select, collection: User.enum_selectors(:user_type)
      f.input :location_range, as: :select, collection: User.enum_selectors(:location_range)

    end
    f.actions
  end

end
