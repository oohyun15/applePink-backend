class SmsCertification < ApplicationRecord
  def self.generate_code phone = nil
    certification_code = self.find_or_create_by(phone: phone)

    # 난수 생성
    genereate_code = rand(999999).to_s.rjust(6, "0")
 
    # 코드 업데이트
    certification_code.update(code: genereate_code)

    Rails.logger.error "generate_code: #{generate_code}, phone: #{phone}"
      
    # SMS 전송
    Cafe24Sms.send_sms(rphone: phone, msg: "[모두나눔] 인증 코드는 #{generate_code}입니다.")
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
