require 'net/https'
require 'pp'

module Casamiento
	class ImportOrders
		def initialize	
			@ebay_api = Ebay::API::Trading.new
			response = @ebay_api.get_orders(:mod_time_from => 300.hours.ago.iso8601, :mod_time_to => Time.now.iso8601)

			result = Hash.from_xml(response.body)
			result = process_xml(result)
		end
		
		def process_xml(result)
			exit if result["GetOrdersResponse"]["PaginationResult"]["TotalNumberOfEntries"] == "0"
			order_array = result["GetOrdersResponse"]["OrderArray"]["Order"]
			if order_array.is_a?(Array)
				order_array.each { |o| process_order(o) }
			else
				process_order(order_array)
			end
		end
		
		def process_order(o)
			pp o
			customer = Customer.find_or_initialize_by_eias_token(o["EIASToken"])
			order = Order.find_or_initialize_by_ebay_order_identifier(o["OrderID"])
			customer.orders << order
			if o["TransactionArray"]["Transaction"].is_a?(Array)
				order.items = o["TransactionArray"]["Transaction"].map { |t| process_transaction(t) }
			else
				order.items = [ process_transaction(o["TransactionArray"]["Transaction"]) ]
			end
			pp customer.orders
		end
		
		def process_transaction(t)
			item_id = t["Item"]["ItemID"]
			response = @ebay_api.get_item(:item_id => item_id, :detail_level => "ItemReturnDescription")
			item = Hash.from_xml(response.body)
			matches = item["GetItemResponse"]["Item"]["Description"].scan(/\[\[CASAMIENTO_SKU::(.*)\]\]/).flatten
			unless matches.first.nil?
				quantity, product_id = matches.first.split('-')
			end
			item = Item.find_or_initialize_by_ebay_order_line_item_token(t["OrderLineItemID"])
			item.quantity_ordered = quantity
			item.product_id = product_id
			item.price = 20
			item
		end
	
	end
end
	

Casamiento::ImportOrders.new
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