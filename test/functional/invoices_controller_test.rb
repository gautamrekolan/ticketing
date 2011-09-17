require 'test_helper'

class InvoicesControllerTest < ActionController::TestCase
  # Replace this with your real tests.
  
  test "the truth" do
    assert true
  end
  
  test "should render index" do
  Factory.create(:order)
    get :index
    assert_response :success
    
    puts @response.body
  end
end
