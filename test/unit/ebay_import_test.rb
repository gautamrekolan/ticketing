require Rails.root.to_s + '/import_customers.rb'

class EbayImportTest < ActiveSupport::TestCase

  test "the truth" do
    assert true
  end
  
  def setup
    EbayLastImportedTime.instance.update_attributes(:last_import => Time.now)
    
    @customer = FactoryGirl.create(:customer, :eias_token => "abcdefghijklmnopqrstuvwxyz")
    @product = FactoryGirl.create(:product)
    
    xml = File.new(File.join(Rails.root.to_s, 'lib', 'test', 'fixtures', 'get_orders_response.xml'))
    xml = xml.read
    
    item = File.new(File.join(Rails.root.to_s, 'lib', 'test', 'fixtures', 'get_item_response.xml'))
    item = item.read
    
    @item = Hash.from_xml(item)
    @xml = Hash.from_xml(xml)
  end
  
  def mock_with_xml
    ebay_api = stub('api', :get_orders => @xml, :get_item => @item)
    Ebay::API::Trading.stubs(:new).returns(ebay_api)
  end
  
  test "creates new customer and order if doesn't already exist" do 
    mock_with_xml
    assert_difference ['Customer.count', 'Order.count'], 1 do
      Casamiento::ImportOrders.new
    end
    new_customer = Customer.find_by_eias_token("nY+sHZ2PrBmdj6wVnY+sEZ2PrA2dj6wFk4CoAZeCoAqdj6x9nY+seQ==")
    assert_equal "Melanie Sykes", new_customer.name
    assert_equal "219315010", new_customer.orders.first.ebay_order_identifier
  end
   
  test "does not create new customer if EIAS token matches" do
    @xml["GetOrdersResponse"]["OrderArray"]["Order"]["EIASToken"] = "abcdefghijklmnopqrstuvwxyz"
    mock_with_xml
    assert_no_difference 'Customer.count' do
      Casamiento::ImportOrders.new
    end
  end
   
  test "adds orders to existing customer if EIAS token matches" do
    @xml["GetOrdersResponse"]["OrderArray"]["Order"]["EIASToken"] = "abcdefghijklmnopqrstuvwxyz"
    mock_with_xml
    assert_difference 'Order.count', 1 do
      Casamiento::ImportOrders.new
    end
    david = Customer.find_by_name("David Pettifer")
    order = david.orders.first
    assert_equal 1, david.orders.count
    assert_equal "219315010", order.ebay_order_identifier     
  end
   
  test "adds address to customer" do 
    mock_with_xml

    assert_difference 'CustomerAddress.count', 1 do
            Casamiento::ImportOrders.new
    end
    
    customer = Customer.find_by_eias_token("nY+sHZ2PrBmdj6wVnY+sEZ2PrA2dj6wFk4CoAZeCoAqdj6x9nY+seQ==")
    assert_equal 1, customer.customer_addresses.count
    address = customer.customer_addresses.first
    assert_equal "116 Kents Hill Road", address.address_1
    assert_equal "Off High Street", address.address_2
    assert_equal "South Benfleet", address.town
    assert_equal "ESSEX", address.county
    assert_equal "United Kingdom", address.country
    assert_equal "SS7 5PJ", address.postcode
  end 
  
  test "doesn't add existing address" do 
      @xml["GetOrdersResponse"]["OrderArray"]["Order"]["ShippingAddress"]["AddressID"] = "5695388"
      mock_with_xml
      @customer.customer_addresses.build(:name => "David", :postcode => "PO37 7LU", :ebay_address_id => "5695388")
      @customer.save
      assert_no_difference 'CustomerAddress.count' do
        Casamiento::ImportOrders.new
      end
  end
   
  test "raises error on Ack Failure" do
    @xml["GetOrdersResponse"]["Ack"] = "Failure"
    mock_with_xml
    assert_raises IOError do
      Casamiento::ImportOrders.new
    end
  end
  
  test "raises error on bad product id" do 
    @item["GetItemResponse"]["Item"]["Description"] = "[[CASAMIENTO_SKU::30-592]]"
    mock_with_xml
    assert_raises ActiveRecord::RecordNotFound do 
        Casamiento::ImportOrders.new
    end
  end
  
  test "adds items correctly" do 
    @item["GetItemResponse"]["Item"]["SellingStatus"]["QuantitySold"] = 3
    mock_with_xml
    Casamiento::ImportOrders.new
    assert_equal 90, Order.first.items.first.quantity_ordered   
  end
  
  test "raises error on retrieve item failure" do
    @item["GetItemResponse"]["Ack"] = "Failure"
    mock_with_xml
    assert_raises IOError do 
        Casamiento::ImportOrders.new
    end
  end
  
  test "updates last imported time" do
    @xml["GetOrdersResponse"]["Timestamp"] = "2011-07-16T23:17:50.999Z"
    mock_with_xml
    Casamiento::ImportOrders.new
    assert_equal Time.parse("17th July 2011 00:17:50 BST").iso8601, EbayLastImportedTime.instance.last_import.iso8601
  end
    
end
