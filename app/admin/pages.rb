ActiveAdmin.register Page do
  menu parent: "3. 사이트 관리", priority: 4, label: "#{I18n.t("activerecord.models.page")} 관리"

  index do
    selectable_column
    id_column
    column :title
    column :page_type do |page| page.page_type.present? ? I18n.t("enum.page.page_type.#{page.page_type}") : ""  end
    column :updated_at do |page| short_date(page.updated_at) end
    column :effective_date do |page| short_date(page.effective_date) end
    column :body do |page| page.body&.truncate(27) end
    actions
  end

  show do
    attributes_table do
      row :title
      row :page_type do |page| page.page_type.present? ? I18n.t("enum.page.page_type.#{page.page_type}") : ""  end
      row :updated_at do |page| short_date(page.updated_at) end
      row :effective_date do |page| short_date(page.effective_date) end
      row :body do |page| simple_format page.body end
    end
  end

  form do |f|
    f.inputs do
      f.input :page_type, as: :select, collection: Page.page_types.map{|key,value| [I18n.t("enum.page.page_type.#{key}"), key]}
      f.input :effective_date, as: :datepicker
      f.input :title
      f.input :body
    end
    f.actions
  end
end
