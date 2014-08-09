require 'test_helper'

class UnitsControllerTest < ActionController::TestCase
  setup do
    @answer = units(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:tasks)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create unit" do
    assert_difference('Unit.count') do
      post :create, answer: @answer.attributes
    end

    assert_redirected_to unit_path(assigns(:answer))
  end

  test "should show unit" do
    get :show, id: @answer
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @answer
    assert_response :success
  end

  test "should update unit" do
    put :update, id: @answer, answer: @answer.attributes
    assert_redirected_to unit_path(assigns(:answer))
  end

  test "should destroy unit" do
    assert_difference('Unit.count', -1) do
      delete :destroy, id: @answer
    end

    assert_redirected_to units_path
  end
end
