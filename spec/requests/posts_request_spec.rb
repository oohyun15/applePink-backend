require 'rails_helper'

describe "Post test", type: :request do
  before(:all) do
    @id = User.first.id
    @email = User.first.email

    post "/users/sign_in", params: {user: {email: "#{@email}", password: "test123"}}
    @token =  JSON.parse(response.body)["token"]
  end

end
