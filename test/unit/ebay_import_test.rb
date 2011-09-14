require 'test_helper'
require 'import_ebay_messages'
class EbayImportTest < ActiveSupport::TestCase

  test "the truth" do
    assert true
  end

  def setup
    EbayLastImportedTime.instance.update_attributes(:last_import => Time.now)
    
    @customer = FactoryGirl.create(:customer, :eias_token => "abcdefghijklmnopqrstuvwxyz")
    @product = FactoryGirl.create(:product)

    shipping_address = { :Name => "Melanie Sykes", :Street1 => "116 Kents Hill Road", :Street2 => "Off High Street", :CityName => "South Benfleet", :StateOrProvince => "ESSEX", :Country => "GB", :CountryName => "United Kingdom", :Phone => "1 800 111 1111", :PostalCode => "SS7 5PJ", :AddressID => "5695388" } 

    @item_response = { :GetItemResponse => { :Item => { :Description => "A beautiful set of invitations for all the family!&lt;br&gt; &lt;br&gt; [[CASAMIENTO_SKU::30-1]]&lt;br&gt;", :ItemID => "110090977477" } } }
    
    @transaction1 = { :Transaction => { :Buyer => { :Email => "david.pettifer@dizzy.co.uk" }, :CreatedDate => "2011-07-14T16:36:27.000Z", :Item => { :ItemID => "110090767031" }, :QuantityPurchased => "1", :OrderLineItemID => "110090767031-0" } }
    @transaction2 = { :Transaction => { :Buyer => { :Email => "david.pettifer@dizzy.co.uk" }, :CreatedDate => "2011-07-14T16:36:27.000Z", :Item => { :ItemID => "110090769997" }, :QuantityPurchased => "1", :OrderLineItemID => "110090769997-0" } }
    
    @order1 = { :Order => { :OrderID => "219315010", :OrderStatus => "Completed", :CheckoutStatus => { :LastModifiedTime => "2011-07-15T09:11:15.000Z", :Status => "Completed" }, :ShippingAddress => shipping_address, :EIASToken => "nY+sHZ2PrBmdj6wVnY+sEZ2PrA2dj6wFk4CoAZeCoAqdj6x9nY+seQ==", :TransactionArray =>  [ @transaction1, @transaction2 ]  } }
    
    @order_response = { :GetOrdersResponse => { :Ack => "Success", :Timestamp => "2011-07-16T23:17:50.311Z", :PaginationResult => { :TotalNumberOfEntries => "3" }, :OrderArray => @order1 } }
  end
  
  def build_xml_and_stub_requests!
    get_item_response = build_xml_from_hash(@item_response)
    get_order_response = build_xml_from_hash(@order_response)
    stub_request(:post, "https://api.ebay.com/ws/api.dll").to_return({:body => get_order_response}, {:body => get_item_response}, { :body => get_item_response } )
  end

  test "1 creates new customer and new order if doesn't already exist" do 
    build_xml_and_stub_requests!
    assert_difference ['Customer.count', 'Order.count'], 1 do
      ImportOrders.new
    end
    new_customer = Customer.find_by_eias_token("nY+sHZ2PrBmdj6wVnY+sEZ2PrA2dj6wFk4CoAZeCoAqdj6x9nY+seQ==")
    assert_equal "Melanie Sykes", new_customer.name
    assert_equal "219315010", new_customer.orders.first.ebay_order_identifier
  end

  test "2 does not create new customer if EIAS token matches" do
    @order1[:Order][:EIASToken] = "abcdefghijklmnopqrstuvwxyz"
    build_xml_and_stub_requests!
    assert_no_difference 'Customer.count' do
      ImportOrders.new
    end
  end

  test "3 adds orders to existing customer if EIAS token matches" do
    @order1[:Order][:EIASToken] =  "abcdefghijklmnopqrstuvwxyz"
    build_xml_and_stub_requests!
       assert_difference 'Order.count', 1 do
      ImportOrders.new
    end
    david = Customer.find_by_name("David Pettifer")
    order = david.orders.first
    assert_equal 1, david.orders.count
    assert_equal "219315010", order.ebay_order_identifier     
  end

  test "4 adds new address to customer if address doesn't exist" do 
    build_xml_and_stub_requests!
    assert_difference 'CustomerAddress.count', 1 do
            ImportOrders.new
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
  
  test "5 doesn't add existing address" do 
     build_xml_and_stub_requests!
      @customer.customer_addresses.build(:name => "David", :postcode => "PO37 7LU", :ebay_address_id => "5695388")
      @customer.save
      assert_no_difference 'CustomerAddress.count' do
        ImportOrders.new
      end
  end

  test "6 adds items correctly" do  
    @transaction1[:Transaction][:QuantityPurchased] = 3
    build_xml_and_stub_requests!
    ImportOrders.new
    assert_equal 90, Order.first.items.first.quantity_ordered   
  end

  test "7 raises error on GetOrdersResponse Ack Failure" do
  #todo need to add xml for errors in mock xml
    @order_response[:GetOrdersResponse][:Ack] = "Failure"
    build_xml_and_stub_requests!
    exception = assert_raises Exception do 
        ImportOrders.new
    end

    assert_equal "Either Order ID, Creation time range, Modified time range or Number of days must be provided.", exception.message
  end
  
  test "8 raises error on bad product id" do 
    @item_response[:GetItemResponse][:Item][:Description].gsub!("CASAMIENTO_SKU::30-1", "CASAMIENTO_SKU::30-592")
    build_xml_and_stub_requests!
    assert_raises ActiveRecord::RecordNotFound do 
        ImportOrders.new
    end
  end
  
  test "9 raises error on no product id" do 
    @item_response[:GetItemResponse][:Item][:Description].gsub!("[[CASAMIENTO_SKU::30-1]]", "")
    build_xml_and_stub_requests!
    assert_raises ActiveRecord::RecordNotFound do 
        ImportOrders.new
    end
  end
  
  test "10 raises error on incomplete SKU" do 
     @item_response[:GetItemResponse][:Item][:Description].gsub!("[[CASAMIENTO_SKU::30-1]]", "[[CASAMIENTO_SKY::3")
    build_xml_and_stub_requests!
    assert_raises ActiveRecord::RecordNotFound do 
        ImportOrders.new
    end
  end
  
  test "11 raises error on retrieve item failure" do
    @item_response = { :GetItemResponse => { :Ack => "Failure", :Timestamp => "2011-08-02T00:15:29.431Z", :Errors => { :ShortMessage => "No <ItemID> exists or <ItemID> is specified as an empty tag.", :LongMessage => "No <ItemID> exists or <ItemID> is specified as an empty tag in the request." } } }
    build_xml_and_stub_requests!
    exception = assert_raises Exception do 
        ImportOrders.new
    end
    assert_equal "No <ItemID> exists or <ItemID> is specified as an empty tag in the request.", exception.message
  end

  test "12 updates last imported time" do
    build_xml_and_stub_requests!
    ImportOrders.new
    assert_equal Time.parse("17th July 2011 00:17:50 BST").iso8601, EbayLastImportedTime.instance.last_import.iso8601
  end
  
  test "13 removes single line item orders if order becomes combined" do
    @order1[:Order][:OrderID] = "110091219777-26469553001"
    @order2 = Marshal.load(Marshal.dump(@order1)) # Deep copy of hash
    @order2[:Order][:OrderID] = "110091219789-26469554001"

    @transaction1[:Transaction][:OrderLineItemID] = "110091219777-26469553001"
    @transaction2[:Transaction][:OrderLineItemID] = "110091219789-26469554001"
    
    @order1[:Order][:TransactionArray] = @transaction1
    @order2[:Order][:TransactionArray] = @transaction2

    @order_response[:GetOrdersResponse][:OrderArray] = [ @order1, @order2 ]

    build_xml_and_stub_requests!
    
    ImportOrders.new    
    assert_equal 2, Order.count
    assert_equal 2, Item.count

    @order1[:Order][:OrderID] = "221979010"
    @order1[:Order][:TransactionArray] = [ @transaction1, @transaction2 ]
    @order_response[:GetOrdersResponse][:OrderArray] = @order1
    build_xml_and_stub_requests!
 
    ImportOrders.new      
    assert_equal 1, Order.count
    assert_equal 2, Item.count

  end
  
  test "14 adds new address to new order" do 
    build_xml_and_stub_requests!
    ImportOrders.new
    order = Order.find_by_ebay_order_identifier("219315010")
    assert_equal 2, order.customer_address.customer_id
  end
  
  test "15 adds new address to existing customer" do 
    @order1[:Order][:EIASToken] = "abcdefghijklmnopqrstuvwxyz"
    build_xml_and_stub_requests!
    ImportOrders.new
    order = Order.find_by_ebay_order_identifier("219315010")
    assert_equal 1, order.customer_address.customer_id
  end
end
