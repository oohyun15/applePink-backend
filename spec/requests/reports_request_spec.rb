require 'rails_helper'
require 'active_support'

describe "Report test", type: :request do
  before(:all) do
    # 유저 중 임의의 유저를 선택함.
    user = User.all.sample
    @id = user.id
    @email = user.email

    post "/users/sign_in", params: {user: {email: "#{@email}", password: "test123"}}
    @token = JSON.parse(response.body)["token"]

    # 테스트용 report 모델 생성
    num = range = Faker::Number.between(from: 5, to: 10)
    num.times do |index|
      target_type = Report::REPORT_MODELS.sample
      model = target_type.capitalize
      report = Report.create!(

      )
    end
  end

  it "question index test" do
    # target_type이 parameter로 들어오는 경우
    target_types = Report::REPORT_MODELS.sample
    get "/reports", params: {target_type: target_types}, headers: {Authorization: @token}
    
    # 조건에 맞는 report가 없을 때
    if JSON.parse(response.body).empty?

    else

    end
    
  end
end