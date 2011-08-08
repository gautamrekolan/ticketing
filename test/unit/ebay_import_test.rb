require 'test_helper'
require Rails.root.to_s + '/lib/casamiento/import_orders'
require 'fakeweb'

class EbayImportTest < ActiveSupport::TestCase

  test "the truth" do
    assert true
  end
  
  def mock_xml_response(file)
    xml_file = File.new(File.join(Rails.root.to_s, 'lib', 'test', 'fixtures', file))
    xml = xml_file.read
  end
  
  def register_xml_files(*responses)
      responses.collect! do |r|
        {:body => r }
      end
      FakeWeb.register_uri(:post, "https://api.sandbox.ebay.com/ws/api.dll", responses)
  end
  
  def setup
    EbayLastImportedTime.instance.update_attributes(:last_import => Time.now)
    
    @customer = FactoryGirl.create(:customer, :eias_token => "abcdefghijklmnopqrstuvwxyz")
    @product = FactoryGirl.create(:product)
    pp @customer.customer_addresses

    @item_response = mock_xml_response('get_item_response.xml')
    @order_response = mock_xml_response('get_orders_response.xml')
  end

  test "creates new customer and new order if doesn't already exist" do 
    register_xml_files(@order_response, @item_response, @item_response)
    assert_difference ['Customer.count', 'Order.count'], 1 do
      Casamiento::ImportOrders.new
    end
    new_customer = Customer.find_by_eias_token("nY+sHZ2PrBmdj6wVnY+sEZ2PrA2dj6wFk4CoAZeCoAqdj6x9nY+seQ==")
    assert_equal "Melanie Sykes", new_customer.name
    assert_equal "219315010", new_customer.orders.first.ebay_order_identifier
  end

  test "does not create new customer if EIAS token matches" do
  @order_response.gsub!("nY+sHZ2PrBmdj6wVnY+sEZ2PrA2dj6wFk4CoAZeCoAqdj6x9nY+seQ==", "abcdefghijklmnopqrstuvwxyz") 
      register_xml_files(@order_response, @item_response, @item_response)
    assert_no_difference 'Customer.count' do
      Casamiento::ImportOrders.new
    end
  end

  test "adds orders to existing customer if EIAS token matches" do
  @order_response.gsub!("nY+sHZ2PrBmdj6wVnY+sEZ2PrA2dj6wFk4CoAZeCoAqdj6x9nY+seQ==", "abcdefghijklmnopqrstuvwxyz") 
      register_xml_files(@order_response, @item_response, @item_response)
       assert_difference 'Order.count', 1 do
      Casamiento::ImportOrders.new
    end
    david = Customer.find_by_name("David Pettifer")
    order = david.orders.first
    assert_equal 1, david.orders.count
    assert_equal "219315010", order.ebay_order_identifier     
  end

  test "adds new address to customer" do 
      register_xml_files(@order_response, @item_response, @item_response)
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
      register_xml_files(@order_response, @item_response, @item_response)
      @customer.customer_addresses.build(:name => "David", :postcode => "PO37 7LU", :ebay_address_id => "5695388")
      @customer.save
      assert_no_difference 'CustomerAddress.count' do
        Casamiento::ImportOrders.new
      end
  end

  test "adds items correctly" do  
      register_xml_files(@order_response, @item_response, @item_response)
    @item_response.gsub!("<QuantitySold>1</QuantitySold>", "<QuantitySold>3</QuantitySold>")
    Casamiento::ImportOrders.new
    assert_equal 90, Order.first.items.first.quantity_ordered   
  end

  test "raises error on GetOrdersResponse Ack Failure" do
  @order_response = mock_xml_response("get_orders_response_error.xml")
       register_xml_files(@order_response, @item_response, @item_response)
    exception = assert_raises Exception do 
        Casamiento::ImportOrders.new
    end

    assert_equal "Either Order ID, Creation time range, Modified time range or Number of days must be provided.", exception.message
  end
  test "raises error on bad product id" do 
        @item_response.gsub!("CASAMIENTO_SKU::30-1", "CASAMIENTO_SKU::30-592") 
             register_xml_files(@order_response, @item_response, @item_response)
    assert_raises ActiveRecord::RecordNotFound do 
        Casamiento::ImportOrders.new
    end
  end
  
  test "raises error on no product id" do 
    @item_response.gsub!("[[CASAMIENTO_SKU::30-1]]", "")
    register_xml_files(@order_response, @item_response, @item_response)
    assert_raises ActiveRecord::RecordNotFound do 
        Casamiento::ImportOrders.new
    end
  end
  
  test "raises error on incomplete SKU" do 
      @item_response.gsub!("[[CASAMIENTO_SKU::30-1]]", "[[CASAMIENTO_SKY::3")
    register_xml_files(@order_response, @item_response, @item_response)
    assert_raises ActiveRecord::RecordNotFound do 
        Casamiento::ImportOrders.new
    end
  end
  
  test "raises error on retrieve item failure" do
      @item_response = mock_xml_response("get_item_response_error.xml")
      register_xml_files(@order_response, @item_response, @item_response)
    exception = assert_raises Exception do 
        Casamiento::ImportOrders.new
    end
    assert_equal "No <ItemID> exists or <ItemID> is specified as an empty tag in the request.", exception.message
  end

  test "updates last imported time" do
      register_xml_files(@order_response, @item_response, @item_response)
    Casamiento::ImportOrders.new
    assert_equal Time.parse("17th July 2011 00:17:50 BST").iso8601, EbayLastImportedTime.instance.last_import.iso8601
  end
  
  test "removes single line item orders if order becomes combined" do
    @order_response = mock_xml_response("get_orders_response_2_items_same_buyer_not_paid.xml")
    register_xml_files(@order_response, @item_response, @item_response)
    
    Casamiento::ImportOrders.new    
    assert_equal 2, Order.count
    assert_equal 2, Item.count
    order_response = mock_xml_response("get_orders_response_4_items_same_buyer_paid.xml")
    register_xml_files(order_response, @item_response, @item_response, @item_response, @item_response)    
    Casamiento::ImportOrders.new
    assert_equal 2, Order.count
    assert_equal 4, Item.count
  end
  
end
