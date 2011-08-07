require File.dirname(__FILE__) + '/../test_helper'

class OrderTest < ActiveSupport::TestCase

  test "the truth" do
    assert true
  end
  
  def setup
    @order = FactoryGirl.create(:order)
  end

  test "delete associated items when order deleted" do
    assert_difference 'Item.count', -2 do 
      @order.destroy
    end  
  end

end
