require 'rails_helper'
require 'active_support'

describe "Company test", type: :request do
  before(:all) do
    # 유저 중 임의의 유저를 선택함.
    @user = User.all.sample
    @id = @user.id
    @email = @user.email

    post "/api/users/sign_in", params: {user: {email: "#{@email}", password: "test123"}}
    @token =  JSON.parse(response.body)["token"]
  end

  xit "Company create test" do
    company_info = {
      company: {
        name: Faker::Name.name,
        phone: Faker::Base.numerify('010########'),
        message: "광고주 신청합니다.",
        description: "모두나눔의 광고주가 되고 싶습니다. 연락주세요.",
        title: "애플핑크",
        business_registration: "0123456789",
        business_address: "경기도 수원시",
        biz_type: "전자소매업",
        category: "애플리케이션",
        location_id: Location.all.pluck(:position).sample
      }
    }
    # 이미 현재 사용자가 이전에 광고주 신청을 했을 경우
    if @user.company.present?
      post "/api/companies", params: company_info, headers: {Authorization: @token}
      # 광고주 신청이 승인됐을 경우
      if @user.company&.approve
        # 이미 광고주라는 메세지를 출력함.
        expect(JSON.parse(response.body)["message"]).to eq("#{@user.nickname}님은 파트너입니다.")
        expect(response).to have_http_status(:ok)
      else
        # 아직 승인 대기 상태일 경우
        expect(JSON.parse(response.body)["message"]).to eq("#{@user.nickname}님은 현재 승인대기 상태입니다.")
        expect(response).to have_http_status(:ok)
      end
    else
      # 이전에 광고주 신청을 하지 않았을 경우
      # 하나라도 nil 값이 들어오면 생성되지 않음.
      company_info[:company][:name] = nil
      post "/api/companies", params: company_info, headers: {Authorization: @token}
      expect(response).to have_http_status(:bad_request)

      # body에 모든 정보를 다 채워넣고 요청을 보냈을 때
      company_info[:company][:name] = Faker::Name.name
      # 신청됐다는 메세지와 함께 승인 대기 중(approve: false)으로 생성됨.
      post "/api/companies", params: company_info, headers: {Authorization: @token}
      expect(JSON.parse(response.body)["message"]).to eq("파트너 신청이 완료되었습니다.")
      expect(response).to have_http_status(:ok)
    end
  end
  
  xit "Company show test" do
    company = Company.all.sample

    get "/api/companies/#{company.id}", headers: {Authorization: @token}

    expect(JSON.parse(response.body)["company_info"]["id"]).to eq(company.id)
  end

  xit "Company destroy test" do
    # 무작위로 광고주 신청을 선택함.
    company = Company.all.sample

    # 그 신청이 자신의 신청이 아닐 경우
    if company.user != @user
      delete "/api/companies/#{company.id}", headers: {Authorization: @token}
      expect(response).to have_http_status(:unauthorized)
    else
      # 본인이 신청한 광고주 신청일 경우
      delete "/api/companies/#{company.id}", headers: {Authorization: @token}
      expect(Company.find_by(id: company.id)).to eq(nil)
      expect(response).to have_http_status(:ok)
    end
  end

end