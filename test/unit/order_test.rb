require 'test_helper'

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

# == Schema Information
#
# Table name: orders
#
#  id                    :integer         not null, primary key
#  monogram              :integer
#  customer_id           :integer
#  customer_address_id   :integer
#  ebay_order_identifier :string(255)
#  status                :string(255)
#  notes                 :text
#  created_at            :datetime
#  updated_at            :datetime
#

