require 'test_helper'

class ApisControllerTest < ActionDispatch::IntegrationTest
  test "should get test" do
    get apis_test_url
    assert_response :success
  end

end
