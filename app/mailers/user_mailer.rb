class UserMailer < ApplicationMailer
  default from: "tonem0809@gmail.com"

  def generate_code(email, generated_code)
    @email = email
    @generated_code = generated_code
    mail(to: email, subject: "[모두나눔] 소속 인증을 위해 확인해주세요!")
  end
end
