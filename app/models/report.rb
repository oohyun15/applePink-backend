class Report < ApplicationRecord
  REPORT_MODELS = %w(User Post)

  belongs_to :user
  belongs_to :report_target, polymorphic: true
end
