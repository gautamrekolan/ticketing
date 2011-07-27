require 'net/https'
require 'pp'

module Casamiento
	class ImportOrders
		def initialize	
			@ebay_api = Ebay::API::Trading.new
			response = @ebay_api.get_orders(:mod_time_from => EbayLastImportedTime.instance.last_import.iso8601, :mod_time_to => Time.now.iso8601)
		
			raise IOError if response["GetOrdersResponse"]["Ack"] == "Failure"
			process_xml(response)
		end
		
		def process_xml(result)
			exit if result["GetOrdersResponse"]["PaginationResult"]["TotalNumberOfEntries"] == "0"
			order_array = result["GetOrdersResponse"]["OrderArray"]["Order"]
			if order_array.is_a?(Array)
				order_array.each { |o| process_order(o) }
			else
				process_order(order_array)
			end
			ebay_timestamp = result["GetOrdersResponse"]["Timestamp"]
			EbayLastImportedTime.instance.update_attributes(:last_import => Time.iso8601(ebay_timestamp))
		end
		
		def process_address(address)
			customer_address = CustomerAddress.find_or_initialize_by_ebay_address_id(address["AddressID"])
			if customer_address.new_record?
				customer_address.name = address["Name"]
				customer_address.address_1 = address["Street1"]
				customer_address.address_2 = address["Street2"]
				customer_address.town = address["CityName"]
				customer_address.county = address["StateOrProvince"]
				customer_address.country = address["CountryName"]
				customer_address.postcode = address["PostalCode"]
			end
			customer_address
		end	
		
		def process_order(o)
			customer = Customer.find_or_initialize_by_eias_token(o["EIASToken"])
			if customer.new_record?
				if o["ShippingAddress"]["Name"].blank?
					customer.name = o["BuyerUserID"] 
				else
					customer.name = o["ShippingAddress"]["Name"]
					customer.customer_addresses << process_address(o["ShippingAddress"])
				end			
				customer.ebay_user_id = o["BuyerUserID"]
			end
			order = Order.find_or_initialize_by_ebay_order_identifier(o["OrderID"])
			customer.orders << order
			if o["TransactionArray"]["Transaction"].is_a?(Array)				
				order.items = o["TransactionArray"]["Transaction"].map { |t| process_transaction(t) }
			else
				order.items = [ process_transaction(o["TransactionArray"]["Transaction"]) ]
			end
			customer.save!
		end
		
		def process_transaction(t)		
			item_id = t["Item"]["ItemID"]
			item = @ebay_api.get_item(:item_id => item_id, :detail_level => "ItemReturnDescription")
			raise IOError if item["GetItemResponse"]["Ack"] == "Failure"
			quantity = item["GetItemResponse"]["Item"]["SellingStatus"]["QuantitySold"]
			matches = item["GetItemResponse"]["Item"]["Description"].scan(/\[\[CASAMIENTO_SKU::(.*)\]\]/).flatten

			unless matches.first.nil?
				sub_quantity, product_id = matches.first.split('-')
			end
			product = Product.find(product_id)
			
			item = Item.find_or_initialize_by_ebay_order_line_item_token(t["OrderLineItemID"])
			item.quantity_ordered = quantity.to_i * sub_quantity.to_i
			item.product = product
			item.price = 20
			item
		end
	end
end
	
#go["GetOrdersResponse"]["OrderArray"]["Order"].each do |o|
#puts "\n\n**************************************************************************\n\n"
	#customer = Customer.find_or_initialize_by_eias_token(o["EIASToken"])
	#if customer.new_record?
	#	customer.name = o["ShippingAddress"]["Name"]
	#	customer.ebay_user_id = o["BuyerUserID"]
		
	#customer.save!
	#end
	#order = Order.find_or_initialize_by_ebay_order_identifier(o["OrderID"])
	#if o["TransactionArray"]["Transaction"].is_a? (Array)
	#	o["TransactionArray"]["Transaction"].each do |t|
	#		pp t["Item"]
	#	end
	#else
	#	pp o["TransactionArray"]["Transaction"]["Item"]
	#end
	#item_id = o["TransactionArray"]["Transaction"]["Item"]["ItemID"]
#	item = order.get_item(:item_id => item_id, :detail_level => "ItemReturnDescription")
#item = Hash.from_xml(item.body)
#pp item
	#pp o
	
	#if order.new_record?		
	#	customer.orders << order
	#end

	#customer.save!
#end