class PostSerializer < ActiveModel::Serializer
  #보여줄 attribute들을 설정함. 현재는 post_detail_info와 post_simple_info를 보여줌
  has_one :user
  attributes %i(post_simple_info post_detail_info)
  
  #조건문이 없으니 default가 됨
  def post_simple_info
    post_simple_scope = ActiveModel::Type::Boolean.new.cast(scope.dig(:params, :post_simple_info))
    {
      title: object.title,
      body: object.body,
      image: object.image_path,
      location: object.location.title,
      status: object.status
    }
  end

  #넘어온 body에서 post_detail_scope가 true일 때만 실행됨
  def post_detail_info
    post_detail_scope = ActiveModel::Type::Boolean.new.cast(scope.dig(:params, :post_detail_info))
    {id: object.id, title: object.title, body: object.body, price: object.price, 
      created_at: object.created_at, updated_at: object.updated_at} if post_detail_scope rescue nil
  end
  
end

