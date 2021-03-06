class SmsCertification < ApplicationRecord
  def self.generate_code phone = nil
    certification_code = self.find_or_create_by(phone: phone)

    # 난수 생성
    generated_code = rand(999999).to_s.rjust(6, "0")
 
    # 코드 업데이트
    certification_code.update(code: generated_code)

    Rails.logger.error "generated_code: #{generated_code}, phone: #{phone}"
      
    # '-' 있는 형식으로 변경
    rphone = phone.insert(3, '-').insert(8, '-')
    # SMS 전송
    Cafe24Sms.send_sms(rphone: rphone, msg: "[모두나눔] 인증 코드는 #{generated_code}입니다.")
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
