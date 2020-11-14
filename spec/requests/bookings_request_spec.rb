require 'rails_helper'
require 'active_support'

describe "Post test", type: :request do
  before(:all) do
    # 유저 중 임의의 유저를 선택함.
    user = User.all.sample
    @id = user.id
    @email = user.email

    post "/users/sign_in", params: {user: {email: "#{@email}", password: "test123"}}
    @token =  JSON.parse(response.body)["token"]
  end
  

end