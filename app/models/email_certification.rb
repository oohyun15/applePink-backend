class EmailCertification < ApplicationRecord
  def self.generate_code email = nil
    result = false
    if self.find_by(email: email)&.confirmed_at&.present?
      # 등록된 사용자
    else
      # 이메일 생성 또는 기존에 인증이
      # 되어있지 않았을 경우 그 이메일 불러옴
      certification_code = self.find_or_create_by(email: email)
      
      # 난수 생성
      generate_code = rand(999999).to_s.rjust(6, "0")

      # 코드 업데이트
      certification_code.update(code: generate_code)

      Rails.logger.error "generate_code: #{generate_code}, email: #{email} #{log_info}"

      UserMailer.generate_code(email, generate_code).deliver_now!
      result = true
    end
    return result
  end

  def check_code received_code = nil
    result = false
    if self.code == received_code
      self.update(confirmed_at: Time.current)
      result = true
    end

    return result
  end
end


