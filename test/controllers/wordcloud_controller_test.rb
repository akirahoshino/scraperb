require 'test_helper'

class WordcloudControllerTest < ActionDispatch::IntegrationTest
  test "should get home" do
    get wordcloud_home_url
    assert_response :success
  end

end
