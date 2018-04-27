require 'test_helper'

class S3sControllerTest < ActionDispatch::IntegrationTest
  setup do
    @s3 = s3s(:one)
  end

  test "should get index" do
    get s3s_url
    assert_response :success
  end

  test "should get new" do
    get new_s3_url
    assert_response :success
  end

  test "should create s3" do
    assert_difference('S3.count') do
      post s3s_url, params: { s3: {  } }
    end

    assert_redirected_to s3_url(S3.last)
  end

  test "should show s3" do
    get s3_url(@s3)
    assert_response :success
  end

  test "should get edit" do
    get edit_s3_url(@s3)
    assert_response :success
  end

  test "should update s3" do
    patch s3_url(@s3), params: { s3: {  } }
    assert_redirected_to s3_url(@s3)
  end

  test "should destroy s3" do
    assert_difference('S3.count', -1) do
      delete s3_url(@s3)
    end

    assert_redirected_to s3s_url
  end
end
