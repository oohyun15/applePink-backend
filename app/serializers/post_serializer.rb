class PostSerializer < ActiveModel::Serializer
  #보여줄 attribute들을 설정함.
  has_one :user
  attributes %i(post_info location_info)
  
  #조건문이 없으니 default가 됨
  def post_info
    post_simple_scope = ActiveModel::Type::Boolean.new.cast(scope.dig(:params, :post_info))
    {
      id: object.id,
      #user_id: object.user_id,
      title: object.title,
      body: object.body,
      price: object.price, 
      post_type: object.post_type,
      category: object.category&.title,
      image: object.image_path,
      location: object.location&.title,
      status: object.status,
      likes_count: object.likes_count,
      like_check: object.likes&.pluck(:user_id).include?(@instance_options[:user_id])
    }
  end

  def location_info
    {title: scope.dig(:location, :title), range: scope.dig(:location, :range)} if scope.dig(:location, :info)
  end

end