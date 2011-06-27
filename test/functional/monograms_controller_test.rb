require 'test_helper'

class MonogramsControllerTest < ActionController::TestCase
  setup do
    @monogram = monograms(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:monograms)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create monogram" do
    assert_difference('Monogram.count') do
      post :create, :monogram => @monogram.attributes
    end

    assert_redirected_to monogram_path(assigns(:monogram))
  end

  test "should show monogram" do
    get :show, :id => @monogram.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @monogram.to_param
    assert_response :success
  end

  test "should update monogram" do
    put :update, :id => @monogram.to_param, :monogram => @monogram.attributes
    assert_redirected_to monogram_path(assigns(:monogram))
  end

  test "should destroy monogram" do
    assert_difference('Monogram.count', -1) do
      delete :destroy, :id => @monogram.to_param
    end

    assert_redirected_to monograms_path
  end
end
