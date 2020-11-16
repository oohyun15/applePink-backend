require 'rails_helper'
require 'active_support'

describe "Question test", type: :request do
  before(:all) do
    # 유저 중 임의의 유저를 선택함.
    user = User.all.sample
    @id = user.id
    @email = user.email

    post "/users/sign_in", params: {user: {email: "#{@email}", password: "test123"}}
    @token =  JSON.parse(response.body)["token"]
  end

  it "question create test" do
    # 문의 생성
    question_info = {question: {title: "문의합니다", body: "문의하겠습니다",
      contact: Faker::Base.numerify('010########')}}
    post "/questions", params: question_info, headers: {Authorization: @token}
    
    # 생성한 문의 삭제
    Question.last.delete
  end
end