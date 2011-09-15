require 'import_ebay_messages'
class EbayOrdersResponse < EbayTradingResponse
  def total_entries
    @response["GetOrdersResponse"]["PaginationResult"]["TotalNumberOfEntries"].to_i
  end
  
  def timestamp
    @response["GetOrdersResponse"]["Timestamp"]
  end
  
  def no_entries?
    total_entries == 0
  end
  
  def orders
    @orders ||= process_orders
  end
  
  private
  
  def process_orders
    order_array = @response["GetOrdersResponse"]["OrderArray"]["Order"]
    if !order_array.is_a?(Array)
	  	[ order_array ]
	  else
	    order_array
		end
  end
end

class EbayTransaction < EbayTradingResponse
  
  def initialize(response)
    super(response)
    process_item_description
  end
  
  def price
    ((BigDecimal.new(@response["TransactionPrice"]) / quantity_purchased)*100).to_i
  end
  
  def item
    @response["Item"]
  end
  
  def process_item_description
  	item = connection.request(:GetItem, :ItemID => item_id, :DetailLevel => "ItemReturnDescription")			
		item_description = item["GetItemResponse"]["Item"]["Description"]
		matches = item_description.scan(/\[\[CASAMIENTO_SKU::(.*)\]\]/).flatten
		unless matches.first.nil?
			@sub_quantity, @product_id = matches.first.split('-')
		end
  end
  
  def product_id
    @product_id.to_i
  end

  def buyer
    @response["Buyer"]
  end
  
  def buyer_email
    buyer["Email"]
  end
  
  def item_id
    item["ItemID"]
  end
  
  def quantity_purchased
    @response["QuantityPurchased"].to_i * @sub_quantity.to_i
  end
  
  def order_line_item_id
    @response["OrderLineItemID"]
  end
end

class EbayOrder < EbayTradingResponse

  def order_id
    @response["OrderID"]
  end
  
  def eias_token
    @response["EIASToken"]
  end
  
  def buyer_user_id
    @response["BuyerUserID"]
  end

  def shipping_address
    @shipping_address ||= EbayShippingAddress.new(@response["ShippingAddress"])
  end
  
  def transactions
    @transactions ||= process_transactions
  end
  
  def process_transactions
    transaction_array = @response["TransactionArray"]["Transaction"]
     if !transaction_array.is_a?(Array)
	  	[ transaction_array ]
	  	else 
	  	  transaction_array
	  	end
  end
  
end

class EbayShippingAddress < EbayTradingResponse

  def name
    @response["Name"]
  end
  
  def street1
    @response["Street1"]
  end

  def street2
    @response["Street2"]
  end

  def city
    @response["CityName"]
  end

  def state
    @response["StateOrProvince"]
  end

  def country
    @response["CountryName"]
  end
  
  def postcode
    @response["PostalCode"]
  end
  
  def address_id
    @response["AddressID"]
  end
end

class ImportOrders
	def initialize	
		@ebay_api = EbayApiConnection.connection
		@orders_to_be_deleted = []
		import!
	end
	
	def import!
	  response = @ebay_api.request(:GetOrders, :ModTimeFrom => EbayLastImportedTime.instance.last_import.iso8601, :ModTimeTo => Time.now.iso8601)
	  orders_response = EbayOrdersResponse.new(response)
	  puts orders_response.no_entries?
		exit if orders_response.no_entries?
		
		orders_response.orders.each do |order|
		  process_order(EbayOrder.new(order))
		end	 			
		
		Order.destroy(@orders_to_be_deleted)
		EbayLastImportedTime.instance.update_attributes(:last_import => Time.iso8601(orders_response.timestamp))
	end

	def process_order(o)
		order = Order.find_or_initialize_by_ebay_order_identifier(o.order_id)

		if order.new_record?
			customer = Customer.find_or_initialize_by_eias_token(o.eias_token)
			if customer.new_record?
				if o.shipping_address.name.blank?
					customer.name = o.buyer_user_id
				else
					customer.name = o.shipping_address.name
				end			
			  customer.ebay_user_id = o.buyer_user_id
			  customer.save!
			end
			address = process_address(o.shipping_address)
			address.customer = customer
			order.customer = customer
			order.customer_address = address
		end 
	  order.items << o.transactions.map { |t| process_transaction(t, o, customer) }
		order.save!
	end
	
	def process_address(address)
		customer_address = CustomerAddress.find_or_initialize_by_ebay_address_id(address.address_id)
		if customer_address.new_record?
			customer_address.name = address.name
			customer_address.address_1 = address.street1
			customer_address.address_2 = address.street2
			customer_address.town = address.city
			customer_address.county = address.state
			customer_address.country = address.country
			customer_address.postcode = address.postcode
		end
		customer_address
	end	
	
	def process_transaction(t, o, c)		
	  transaction = EbayTransaction.new(t)
		if !transaction.buyer_email.blank? || transaction.buyer_email != "Invalid Request"
		  email = CustomerEmail.find_or_initialize_by_address(transaction.buyer_email)
		  email.save! if email.new_record?
		  c.customer_emails << email
		end

    # Delete order if it has been combined
		if order = Order.find_by_ebay_order_identifier(transaction.order_line_item_id)
			@orders_to_be_deleted << order.id
		end
		
		item = Item.find_or_initialize_by_ebay_order_line_item_token(transaction.order_line_item_id)
		item.quantity_ordered = transaction.quantity_purchased
		product = Product.find(transaction.product_id)
		item.product = product
		item.price = transaction.price
		item
	end

end

