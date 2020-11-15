class LocationSerializer < ActiveModel::Serializer
  attributes %i(location_info)
 
  def location_info
    @alone = [object.title]
    @near = Location.where(id: object.location_near).pluck(:title)
    @normal = Location.where(id: object.location_normal).pluck(:title)
    @far = Location.where(id: object.location_far).pluck(:title)

    location_scope = ActiveModel::Type::Boolean.new.cast(scope.dig(:params, :location_info))
    {
      alone: {
        title: @alone,
        count: @alone.size
      },
      near: {
        title: @near,
        count: @near.size
      },
      normal: {
        title: @normal,
        count: @normal.size
      },
      far: {
        title: @far,
        count: @far.size
      }
    }
  end
end
