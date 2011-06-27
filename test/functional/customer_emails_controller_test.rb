require 'test_helper'

class CustomerEmailsControllerTest < ActionController::TestCase
  setup do
    @customer_email = customer_emails(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:customer_emails)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create customer_email" do
    assert_difference('CustomerEmail.count') do
      post :create, :customer_email => @customer_email.attributes
    end

    assert_redirected_to customer_email_path(assigns(:customer_email))
  end

  test "should show customer_email" do
    get :show, :id => @customer_email.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @customer_email.to_param
    assert_response :success
  end

  test "should update customer_email" do
    put :update, :id => @customer_email.to_param, :customer_email => @customer_email.attributes
    assert_redirected_to customer_email_path(assigns(:customer_email))
  end

  test "should destroy customer_email" do
    assert_difference('CustomerEmail.count', -1) do
      delete :destroy, :id => @customer_email.to_param
    end

    assert_redirected_to customer_emails_path
  end
end
