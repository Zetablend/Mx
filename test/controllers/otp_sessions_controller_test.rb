require "test_helper"

class OtpSessionsControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get otp_sessions_new_url
    assert_response :success
  end

  test "should get verify" do
    get otp_sessions_verify_url
    assert_response :success
  end
end
