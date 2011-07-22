require '../test_helper'
require '../../import_customers.rb'

class EbayImportTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
  
  def setup
    @customer = Factory.create(:customer, :eias_token => "abcdefghijklmnopqrstuvwxyz")
    
    xml = File.new(File.join(Rails.root.to_s, 'lib', 'test', 'fixtures', 'get_orders_response.xml'))
    xml = xml.read
    @xml = Hash.from_xml(xml)
  end
  
  test "creates new customer if doesn't already exist" do 
    
    Ebay::API::Trading.any_instance.stubs(:get_orders).returns(@xml)
        assert_difference 'Customer.count', 1 do
         Casamiento::ImportOrders.new
        end
    new_customer = Customer.find_by_eias_token("nY+sHZ2PrBmdj6wVnY+sEZ2PrA2dj6wFk4CoAZeCoAqdj6x9nY+seQ==")
    assert_equal "Melanie Sykes", new_customer.name
   end
   
   test "does not create new customer if EIAS token matches" do
    @xml["GetOrdersResponse"]["OrderArray"]["Order"]["EIASToken"] = "abcdefghijklmnopqrstuvwxyz"
    Ebay::API::Trading.any_instance.stubs(:get_orders).returns(@xml)

    assert_no_difference 'Customer.count' do
        Casamiento::ImportOrders.new
    end
    end
    
    test "adds orders to existing customer if EIAS token matches" do
        @xml["GetOrdersResponse"]["OrderArray"]["Order"]["EIASToken"] = "abcdefghijklmnopqrstuvwxyz"
    Ebay::API::Trading.any_instance.stubs(:get_orders).returns(@xml)
     assert_difference 'Order.count', 1 do
        Casamiento::ImportOrders.new
    end
     david = Customer.find_by_name("David Pettifer")
     order = david.orders.first
     assert_equal 1, david.orders.count
     assert_equal "219315010", order.ebay_order_identifier     
    end
    
end
