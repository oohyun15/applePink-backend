ActiveAdmin.register Page do
  menu parent: "3. 사이트 관리", priority: 4, label: "#{I18n.t("activerecord.models.page")} 관리"

  index do
    selectable_column
    id_column
    column :title
    column :page_type do |page| page.page_type.present? ? I18n.t("enum.page.page_type.#{page.page_type}") : ""  end
    column :body do |page| page.body&.truncate(27) end
    column :created_at
    column :updated_at
    actions
  end

  show do
    attributes_table do
      row :title
      row :page_type do |page| page.page_type.present? ? I18n.t("enum.page.page_type.#{page.page_type}") : ""  end
      row :body do |page| simple_format page.body end
      row :created_at
      row :updated_at
    end
  end

  form do |f|
    f.inputs do
      f.input :page_type, as: :select, collection: Page.page_types.map{|key,value| [I18n.t("enum.page.page_type.#{key}"), key]}
      f.input :title
      f.input :body
    end
    f.actions
  end
end
