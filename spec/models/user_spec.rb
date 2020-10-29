require 'rails_helper'

RSpec.describe User, type: :model do
  #사용자 로그인 관련 테스트
  context 'user sign_in test' do
    it 'wrong email' do
      test_user = User.find_by(email: 'tester1@test.com.net')
      expect(test_user).to eq(nil)
    end

    it 'wrong password' do
      test_user = User.find_by(email: 'tester1@test.com')
      expect(test_user.authenticate('test1234')).to eq(false)
    end
  end

  context 'user sign_up test' do
    it 'need_email' do
      test_user = User.new(email: nil, nickname: 'applePink', password: 'test123').save
      expect(test_user).to eq(false)
    end

    it 'need_nickname' do
      test_user = User.new(email: 'applePink@test.com', nickname: nil, password: 'test123').save
      expect(test_user).to eq(false)
    end

    it 'need_password' do
      test_user = User.new(email: 'applePink@test.com', nickname: 'applePink', password: nil).save
      expect(test_user).to eq(false)
    end 

    it 'success_case' do
      test_user = User.new(email: 'applePink@test.com', nickname: 'applePink', password: 'test123').save
      expect(test_user).to eq(true)
    end
  end
end
