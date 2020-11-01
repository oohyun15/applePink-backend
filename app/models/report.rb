class Report < ApplicationRecord
  include Imagable

  REPORT_MODELS = %w(User Post)
  REPORT_COLUMNS = %i(target_id target_type detail reason) + [images_attributes: %i(imagable_type imagable_id image)]

  validates :reason, presence: true

  belongs_to :user
  belongs_to :target, polymorphic: true, counter_cache: true

  # 신고 사유
  # 허위 매물, 계약사항 위반, 연락 두절, 부적절한 말, 적합하지 않은 게시글(높은 가격, 부적절한 물품), 사기 의심, 폭력 및 협박, 기타 사유
  enum reason: %i(fake_item break_rule lost_contact impertinence unsuitable_post fraud threat_violence etc) 
end
