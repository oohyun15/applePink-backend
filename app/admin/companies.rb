ActiveAdmin.register Company do
  menu parent: "1. 유저 관리", priority: 2, label: "#{I18n.t("activerecord.models.company")} 관리"

  index do
    selectable_column
    id_column
    br
    column :image do |company| image_tag(company&.image_path ,class: 'admin-index-image') end
    column :user
    column :name
    column :phone
    column :location
    column :message
    column :description
    tag_column :approve do |company| company.approve ? "accepted" : "rejected" end
    column("승인관리") do |company|
      if company.approve
        link_to "승인취소", confirm_api_company_path(company.id, approve: false), method: :patch
      else
        link_to "승인하기", confirm_api_company_path(company.id, approve: true), method: :patch
      end
    end
    actions
  end

  show do
    attributes_table do
      row :user
      row :name
      row :image do |company| image_tag(company&.image_path ,class: 'admin-show-image') end
      row :phone
      row :location
      row :message
      row :description
      tag_row :approve do |company| company.approve ? "accepted" : "rejected" end
      row("승인관리") do |company|
        if company.approve
          link_to "승인취소", confirm_api_company_path(company.id, approve: false), method: :patch
        else
          link_to "승인하기", confirm_api_company_path(company.id, approve: true), method: :patch
        end
      end
    end
  end

  form do |f|
    f.inputs do
      f.input :name
      f.input :phone
      f.input :location, as: :select, collection: Location.all.map{|type| [type.title, type.position]}
      f.input :message
      f.input :description
      f.input :image, as: :file, hint: image_tag(f.object&.image_path, class: 'admin-show-image')
      f.input :approve
    end
  end
end
