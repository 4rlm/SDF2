require 'test_helper'

class ContActivitiesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @cont_activity = cont_activities(:one)
  end

  test "should get index" do
    get cont_activities_url
    assert_response :success
  end

  test "should get new" do
    get new_cont_activity_url
    assert_response :success
  end

  test "should create cont_activity" do
    assert_difference('ContActivity.count') do
      post cont_activities_url, params: { cont_activity: {  } }
    end

    assert_redirected_to cont_activity_url(ContActivity.last)
  end

  test "should show cont_activity" do
    get cont_activity_url(@cont_activity)
    assert_response :success
  end

  test "should get edit" do
    get edit_cont_activity_url(@cont_activity)
    assert_response :success
  end

  test "should update cont_activity" do
    patch cont_activity_url(@cont_activity), params: { cont_activity: {  } }
    assert_redirected_to cont_activity_url(@cont_activity)
  end

  test "should destroy cont_activity" do
    assert_difference('ContActivity.count', -1) do
      delete cont_activity_url(@cont_activity)
    end

    assert_redirected_to cont_activities_url
  end
end
