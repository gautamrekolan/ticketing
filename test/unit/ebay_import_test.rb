require '../test_helper'
require '../../import_customers.rb'

class EbayImportTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
  
  test "mocked object" do 
    xml = File.new(File.join(Rails.root.to_s, 'lib', 'test', 'fixtures', 'get_orders_response.xml'))
    xml = xml.read
    Ebay::API::Trading.any_instance.stubs(:get_orders).returns(xml)
    
    assert_equal Order.count, 0, "Before"

  Casamiento::ImportOrders.new
 pp Customer.first.orders
   end
  
end
