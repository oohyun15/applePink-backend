class UserMailer < ApplicationMailer
  default from: "tonem0809@gmail.com"
  # default from: "sakiss4774@gmail.com"

  def generate_code(email, generated_code, type)
    @email = email
    @generated_code = generated_code
    @type = type
    case @type
    when "group"
      mail(
        to: email,
        subject: "[모두나눔] 소속 인증을 위해 확인해주세요!"
      )
    when "find"
      mail(
        to: email,
        subject: "[모두나눔] 비밀번호 찾기를 위한 인증 번호입니다."
      )
    end
  end
end
