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
    column :location do |user| user.is_location_auth? ? user.location : "지역인증 필요" end
    column :expire_time do |user|  user.is_location_auth? ? long_time(user.expire_time) : "지역인증 필요" end
    column :gender do |user| I18n.t("enum.user.gender.#{user.gender}") end
    column :location_range do |user| user.user_type.present? ? I18n.t("enum.user.location_range.#{user.location_range}") : "미지정" end
    column :created_at do |user| short_date user.created_at end
    column :updated_at do |user| short_date user.updated_at end
    column :likes_count do |user| "#{number_with_delimiter user.likes_count}개" end
    column :reports_count do |user| "#{number_with_delimiter user.reports_count}개" end
    # tag_column :user_type do |user| user.user_type.present? ? user.user_type : "미지정" end
    column :user_type do |user|
      if user.is_company?
        link_to "광고주", admin_company_path(user.company), class: "status_tag company"
      else
        span "일반", class: "status_tag normal"
      end
    end
    tag_column :account_type do |user| user.account_type end
    actions
  end

  show do |post|
    attributes_table do
      row :image do |user| image_tag(user&.image_path ,class: 'admin-show-image') end
      row :nickname
      row :email
      row :location do |user| user.is_location_auth? ? user.location : "지역인증 필요" end
      row :expire_time do |user|  user.is_location_auth? ? long_time(user.expire_time) : "지역인증 필요" end
      tag_row :gender
      row :location_range do |user| user.location_range.present? ? I18n.t("enum.user.location_range.#{user.location_range}") : "미지정" end
      row :created_at do |user| short_date user.created_at end
      row :updated_at do |user| short_date user.updated_at end
      row :likes_count do |user| "#{number_with_delimiter user.likes_count}개" end
      row "좋아요한 유저" do |user| User.where(id: user.received_likes.pluck(:user_id)).limit(10) end
      row :reports_count do |user| "#{number_with_delimiter user.reports_count}개" end
      # tag_row :user_type do |user| user.user_type.present? ? user.user_type : "미지정" end
      row :user_type do |user|
        if user.is_company?
          link_to "광고주", admin_company_path(user.company), class: "status_tag company"
        else
          span "일반", class: "status_tag normal"
        end
      end
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
