require '../test_helper'
require '../../import_customers.rb'

class EbayImportTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
  
  def setup
    @customer = Factory.create(:customer)
  end
  
  test "mocked object" do 
    xml = File.new(File.join(Rails.root.to_s, 'lib', 'test', 'fixtures', 'get_orders_response.xml'))
    xml = xml.read
    xml = Hash.from_xml(xml)
    
    Ebay::API::Trading.any_instance.stubs(:get_orders).returns(xml)
    
    assert_equal Order.count, 0, "Before"

        Casamiento::ImportOrders.new
        assert_equal Order.count, 3, "After"
   end
  
end
