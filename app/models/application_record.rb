class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  def self.enum_selectors(column_name)
    I18n.t("enum.#{self.name.underscore}.#{column_name}").invert rescue []
  end
end
