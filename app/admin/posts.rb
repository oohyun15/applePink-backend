ActiveAdmin.register Post do
  menu parent: "2. 서비스 관리", priority: 1, label: "#{I18n.t("activerecord.models.post")} 관리"

  filter :title_cont, label: "#{I18n.t("activerecord.attributes.post.title")} 필터"
  filter :user, label: "#{I18n.t("activerecord.attributes.post.user")} 필터"
  filter :category, as: :select, multiple: true, collection: Category.all.map{|type| [type.title, type.id]}, label: "#{I18n.t("activerecord.models.category")} 필터"
  filter :location, as: :select, multiple: true, collection: Location.all.map{|type| [type.title, type.id]}, label: "#{I18n.t("activerecord.models.location")} 필터"
  filter :post_type, as: :select, multiple: true, collection: Post.post_types.map{|type| [I18n.t("enum.post.post_type.#{type[0]}"), type[1]]}, label: "#{I18n.t("activerecord.attributes.post.post_type")} 필터"
  filter :status, as: :select, multiple: true, collection: Post.statuses.map{|type| [I18n.t("enum.post.status.#{type[0]}"), type[1]]}, label: "상태 필터"

  index do
    selectable_column
    br
    a link_to ("제공 서비스 보기"), "/admin/posts?q%5Bpost_type_in%5D%5B%5D=0", class: "button small"
    a link_to ("요청 서비스 보기"), "/admin/posts?q%5Bpost_type_in%5D%5B%5D=1", class: "button small"
    a link_to ("모두 보기"), "/admin/posts", class: "button small"
    
    column :title
    column :post_type do |post| post.post_type.present? ? I18n.t("enum.post.post_type.#{post.post_type}") : "게시글 타입 없음<br>비정상적인 게시글".html_safe end
    column :image do |post| image_tag(post&.image_path ,class: 'admin-index-image') end
    column :user do |post| post.user end
    column :body do |post| post&.body&.truncate(27) end
    column :category
    column :location do |post| post.location.present? ? post.location : "없음" end
    column :rent_count
    tag_column :status do |post| post.status.present? ? post.status : "게시글 상태 없음<br>비정상적인 게시글".html_safe end
    actions
  end
end
