ActiveAdmin.register Company do

  index do
    selectable_column
    id_column
    br
    column :user do |company| link_to company.user.email, admin_user_path(company.user) end
    column :name
    column :image do |company| image_tag(company&.image_path ,class: 'admin-index-image') end
    column :phone
    column :location
    column :message
    column :description
    tag_column :approve do |company| company.approve ? "accepted" : "rejected" end
    column("승인관리") do |company|
      if company.approve
        link_to "승인취소", confirm_company_path(company.id, approve: false), method: :patch
      else
        link_to "승인하기", confirm_company_path(company.id, approve: true), method: :patch
      end
    end
  end
end
