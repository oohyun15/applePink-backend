require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  render_views

  describe "users_controller" do
    it "#create" do
      params = {
        user: {
          email: Faker::Internet.email,
          nickname: Faker::Name.name,
          password: "test123",
          password_confirmation: "test123"
        }
      }
      post :create, params: params
      expect(response).to have_http_status(200)
      json = JSON.parse(response.body)
      expect(json).to eq nil
    end
  end
end