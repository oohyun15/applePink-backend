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
      target_id = (model == "User") ? (model.constantize.all.ids - [@id]).sample : model.constantize.all.ids.sample

      report = Report.create!(
        user_id: @id,
        target_id: target_id,
        target_type: target_type,
        detail: "테스트 신고",
        reason: Faker::Number.between(from: 0, to: 7)
      )
    end
  end

  it "report index test" do
    # target_type이 parameter로 들어오는 경우
    target_type = Report::REPORT_MODELS.sample
    get "/reports", params: {target_type: target_type}, headers: {Authorization: @token}
    
    # response로 넘어온 데이터와 직접 뽑아낸 데이터가 일치하는 지 확인함.
    ids = []
    JSON.parse(response.body).each do |report|
      ids << report["id"]
    end
    report_ids = Report.where(user_id: @id, target_type: target_type).ids
    expect(report_ids - ids).to eq([])
    
    # target_type이 parameter로 들어오지 않는 경우
    get "/reports", headers: {Authorization: @token}

    ids = []
    JSON.parse(response.body).each do |report|
      ids << report["id"]
    end
    report_ids = Report.where(user_id: @id).ids
    expect(report_ids - ids).to eq([])
  end
end