module Positionable
  extend ActiveSupport::Concern
  included do
    acts_as_list column: :position
    default_scope { order(position: :asc) }
  end
end
