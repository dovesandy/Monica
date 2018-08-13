require 'test_helper'

class SandylaiControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get sandylai_index_url
    assert_response :success
  end

end
