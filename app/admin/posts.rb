ActiveAdmin.register Post do
  menu parent: "2. 서비스 관리", priority: 1, label: "#{I18n.t("activerecord.models.post")} 관리"

  filter :title_cont, label: "#{I18n.t("activerecord.attributes.post.title")} 필터"
  filter :user, label: "#{I18n.t("activerecord.attributes.post.user")} 필터"
  filter :category, as: :select, multiple: true, collection: Category.all.map{|type| [type.title, type.id]}, label: "#{I18n.t("activerecord.models.category")} 필터"
  filter :location, as: :select, multiple: true, collection: Location.all.map{|type| [type.title, type.position]}, label: "#{I18n.t("activerecord.models.location")} 필터"
  filter :post_type, as: :select, multiple: true, collection: Post.post_types.map{|type| [I18n.t("enum.post.post_type.#{type[0]}"), type[1]]}, label: "#{I18n.t("activerecord.attributes.post.post_type")} 필터"
  filter :status, as: :select, multiple: true, collection: Post.statuses.map{|type| [I18n.t("enum.post.status.#{type[0]}"), type[1]]}, label: "상태 필터"

  index do
    selectable_column
    id_column
    br
    a link_to ("제공 서비스 보기"), "/admin/posts?q%5Bpost_type_in%5D%5B%5D=0", class: "button small"
    a link_to ("요청 서비스 보기"), "/admin/posts?q%5Bpost_type_in%5D%5B%5D=1", class: "button small"
    a link_to ("모두 보기"), "/admin/posts", class: "button small"
    
    column :title
    column :post_type do |post| post.post_type.present? ? I18n.t("enum.post.post_type.#{post.post_type}") : "게시글 타입 없음<br>비정상적인 게시글".html_safe end
    column :image do |post| image_tag(post&.image_path ,class: 'admin-index-image') end
    column :user do |post| post.user end
    column :price do |post| money post.price end
    column :body do |post| post&.body&.truncate(27) end
    column :category
    column :location do |post| post.location.present? ? post.location : "없음" end
    column :rent_count do |post| "#{number_with_delimiter post.rent_count}번" end
    column :likes_count do |post| "#{number_with_delimiter post.likes_count}개" end
    column :reports_count do |post| "#{number_with_delimiter post.reports_count}개" end
    column :contract do |post| post.contract&.truncate(20) end
    column :created_at do |post| long_time post.created_at end
    column :updated_at do |post| long_time post.updated_at end
    tag_column :status do |post| post.status.present? ? post.status : "게시글 상태 없음<br>비정상적인 게시글".html_safe end
    actions
  end

  show do
    attributes_table do
      # row :id
      row :title
      row :post_type do |post| post.post_type.present? ? I18n.t("enum.post.post_type.#{post.post_type}") : "게시글 타입 없음<br>비정상적인 게시글".html_safe end
      row :user do |post| post.user end
      row :price do |post| money post.price end
      row :body
      row :category
      row :location do |post| post.location.present? ? post.location : "없음" end
      row :rent_count do |post| "#{number_with_delimiter post.rent_count}번" end
      row :likes_count do |post| "#{number_with_delimiter post.likes_count}개" end
      row "좋아요한 유저" do |post| User.where(id: post.likes.pluck(:user_id)).limit(10) end
      row :reports_count do |post| "#{number_with_delimiter post.reports_count}개" end
      row :contract
      row :image do |post| image_tag(post.image_path ,class: 'admin-show-image') end
      row :created_at do |post| long_time post.created_at end
      row :updated_at do |post| long_time post.updated_at end
      tag_row :status do |post| post.status.present? ? post.status : "게시글 상태 없음<br>비정상적인 게시글".html_safe end      
      panel '이미지 리스트' do
        table_for '이미지' do
          post.images.each_with_index do |image, index|
            column "상세이미지#{index + 1}" do
              image_tag(image.image_path ,class: 'admin-show-image')
            end
          end
        end
      end

    end
  end

  form do |f|
    f.inputs do

      f.input :title
      f.input :post_type, as: :select, collection: Post.enum_selectors(:post_type)
      f.input :price
      f.input :body
      f.input :category_id, as: :select, collection: Category.all.map{|category| [category.title, category.id]}
      f.input :location_id, as: :select, collection: Location.all.map{|location| [location.title, location.id]}
      f.input :status, as: :select, collection: Post.enum_selectors(:status)

      f.input :image, as: :file, hint: image_tag(f.object&.image_path, class: 'admin-show-image')
      f.has_many :images, allow_destroy: true do |p|
        #p.object.image = image_tag(p.object.image_path)
        p.inputs '사진업로드' do
          p.input :image, as: :file, hint: image_tag(p.object.image_path, class: 'admin-show-image' )
          # p.input :image_cache, as: :hidden
        end
      end
    end
    f.actions
  end
end
