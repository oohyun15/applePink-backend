require 'test_helper'

class ApiControllerTest < ActionDispatch::IntegrationTest
  test "should get test" do
    get api_test_url
    assert_response :success
  end

end
