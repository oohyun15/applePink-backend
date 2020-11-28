class LocationSerializer < ActiveModel::Serializer
  attributes %i(location_info)
 
  def location_info
    @alone = [object.title]
    @near = Location.where(position: object.location_near).pluck(:title)
    @normal = Location.where(position: object.location_normal).pluck(:title)
    @far = Location.where(position: object.location_far).pluck(:title)
    begin
      @user = User.find(@instance_options[:user_id])
    rescue => e
      Rails.logger.error "ERROR: 없는 유저입니다. #{log_info}"
      render json: {error: "없는 유저입니다."}, status: :bad_request
    end
    location_scope = ActiveModel::Type::Boolean.new.cast(scope.dig(:params, :location_info))
    {
      id: object.id,
      user_range: 
        case @user&.location_range
        when "location_alone"
          0
        when "location_near"
          1
        when "location_normal"
          2
        when "location_far"
          3         
        end,
      range: [
        {
          title: @alone,
          count: @alone.size
        },
        {
          title: @near,
          count: @near.size
        },
        {
          title: @normal,
          count: @normal.size
        },
        {
          title: @far,
          count: @far.size
        }
      ]
    }
  end
end
