require 'test_helper'

class WebActivitiesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @web_activity = web_activities(:one)
  end

  test "should get index" do
    get web_activities_url
    assert_response :success
  end

  test "should get new" do
    get new_web_activity_url
    assert_response :success
  end

  test "should create web_activity" do
    assert_difference('WebActivity.count') do
      post web_activities_url, params: { web_activity: {  } }
    end

    assert_redirected_to web_activity_url(WebActivity.last)
  end

  test "should show web_activity" do
    get web_activity_url(@web_activity)
    assert_response :success
  end

  test "should get edit" do
    get edit_web_activity_url(@web_activity)
    assert_response :success
  end

  test "should update web_activity" do
    patch web_activity_url(@web_activity), params: { web_activity: {  } }
    assert_redirected_to web_activity_url(@web_activity)
  end

  test "should destroy web_activity" do
    assert_difference('WebActivity.count', -1) do
      delete web_activity_url(@web_activity)
    end

    assert_redirected_to web_activities_url
  end
end
