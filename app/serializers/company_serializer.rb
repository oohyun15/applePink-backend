class CompanySerializer < ActiveModel::Serializer
  has_one :user
  attributes %i(company_info)

  def company_info
    company_scope = ActiveModel::Type::Boolean.new.cast(scope.dig(:params, :company_info))
    {
      id: object.id,
      name: object.name,
      phone: object.phone,
      # image: object.image_path,
      message: object.message,
      description: object.description,
      location: object.location,
      title: object.title,
      business_registration: object.business_registration,
      business_address: object.business_address,
      biz_type: object.biz_type,
      category: object.category,
      approve: object.approve,
    }
  end
end
