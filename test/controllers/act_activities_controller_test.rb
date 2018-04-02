require 'test_helper'

class ActActivitiesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @act_activity = act_activities(:one)
  end

  test "should get index" do
    get act_activities_url
    assert_response :success
  end

  test "should get new" do
    get new_act_activity_url
    assert_response :success
  end

  test "should create act_activity" do
    assert_difference('ActActivity.count') do
      post act_activities_url, params: { act_activity: {  } }
    end

    assert_redirected_to act_activity_url(ActActivity.last)
  end

  test "should show act_activity" do
    get act_activity_url(@act_activity)
    assert_response :success
  end

  test "should get edit" do
    get edit_act_activity_url(@act_activity)
    assert_response :success
  end

  test "should update act_activity" do
    patch act_activity_url(@act_activity), params: { act_activity: {  } }
    assert_redirected_to act_activity_url(@act_activity)
  end

  test "should destroy act_activity" do
    assert_difference('ActActivity.count', -1) do
      delete act_activity_url(@act_activity)
    end

    assert_redirected_to act_activities_url
  end
end
