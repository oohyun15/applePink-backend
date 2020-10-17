ActiveAdmin.register User do
  
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
    tag_column :gender
    tag_column :user_type do |user| user.user_type.present? ? I18n.t("enum.user.user_type.#{user.user_type}") : "미지정" end
    column :created_at
    column :updated_at
    column :account_type do |user| I18n.t("enum.user.account_type.#{user.account_type}") end
    actions
  end

  show do |post|
    attributes_table do
      row :image do |user| image_tag(user&.image_path ,class: 'admin-show-image') end
      row :nickname
      row :email
      row :gender
      row :user_type do |user| user.user_type.present? ? I18n.t("enum.user.user_type.#{user.user_type}") : "미지정" end
      row :lat do |user| number_to_currency(user.lat, unit: '') end
      row :lng do |user| number_to_currency(user.lng, unit: '') end
      row :created_at
      row :updated_at
      row :account_type do |user| I18n.t("enum.user.account_type.#{user.account_type}") end
    end
  end

  form do |f|
    f.inputs do
      f.input :nickname
      f.input :email
      f.input :gender
      f.input :image, as: :file, hint: image_tag(f.object&.image_path, class: 'admin-show-image')
      f.input :user_type, as: :select, collection: User.enum_selectors(:user_type)

    end
    f.actions
  end

end
