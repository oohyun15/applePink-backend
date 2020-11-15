class LocationSerializer < ActiveModel::Serializer
  attributes %i(location_info)
 
  def location_info
    @alone = [object.title]
    @near = Location.where(position: object.location_near).pluck(:title)
    @normal = Location.where(position: object.location_normal).pluck(:title)
    @far = Location.where(position: object.location_far).pluck(:title)

    location_scope = ActiveModel::Type::Boolean.new.cast(scope.dig(:params, :location_info))
    {
      id: object.id,
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
