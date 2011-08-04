require 'net/https'
require 'builder'

module Casamiento
	class ImportOrders
		def initialize	
			@ebay_api = Ebay::Api::Trading.new("https://api.sandbox.ebay.com/ws/api.dll", "AgAAAA**AQAAAA**aAAAAA**kRoiTg**nY+sHZ2PrBmdj6wVnY+sEZ2PrA2dj6wFk4CoAZeCpQ6dj6x9nY+seQ**JpMBAA**AAMAAA**oZA6Ywa6Ma6zNlkw3cqilP+685HQPlP4Bf1XAf+2Rt9V77dU94zFnoj4nhflnUipahn1Fy2roxApfA5ELDRgedWuspTUBirBQ5bAsuq9Btysg3p4KCq5+vsLLi3gyElWAOOOEvjTe24GHXDyHxrJsci0Ht3gMvOQ0rllbdiplsymNRY0+lXrS4jGrLRV3VCwbA2rAuhDhEaJbBH0GNP+YRO2GEerOQUGmA1/zeGYOfa/ZyU/7vQYZoBFG+v+31rxfqlOVo53o9lOo2QVfI1TDRtlsQBaBe159Shbe686AdRod5zAlimUtpzV9/9OqeMDGHqjWi39CsCjTDctOsLm3Ck/h8nJcOkOHCa2aDvW1ney+77L8HljBIBCNBkNookq13s51zRjQh+vekwBi2ja0hZgIlKULFp3QZdF8np9qlhPjWT90udSQiy2hczfFQmK/vCW2dY8OD+6bcPLQa/ruTVMMLQKga3Hdi4oFxJlhLcH3hpi4Z4vunOYnxGhtva2iQpLUfRBwHpCNr2swDQDT8Y4BLkn0GpNAqaOBX700f+uywf0BnOwYwdyL7+kx/8TMR0lwTJvmlPguukEY/zMtrTIChiX6sDAAXTep9H5plEvUKmBwwqxo+Jy15kIkkmMQh5eq58I+/Zw+PWF7sNn7rWLTQyqexrPImWG3hqQlNF2O4F29DWQCfKtiD+Y+RzOF3vngtgeQmCbdWKnP9OXaxIitTuRsDagj5ebjU0DNWkX5/6eQlDScp3fVMNi0pgf", "Casmient-2aff-4dab-9163-50f440216b96", "454dd9f0-47d0-4871-ab91-ab0038a59cd3", "c8d4d396-f869-44d9-8798-df4c2de90717", "727")
			@orders_to_be_deleted = []
			response = @ebay_api.request(:GetOrders, :ModTimeFrom => EbayLastImportedTime.instance.last_import.iso8601, :ModTimeTo => Time.now.iso8601)
			process_xml(response)
			Order.destroy(@orders_to_be_deleted)
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
			items = []
			if o["TransactionArray"]["Transaction"].is_a?(Array)				
				items << o["TransactionArray"]["Transaction"].map { |t| process_transaction(t, o) }
			else
				items << [ process_transaction(o["TransactionArray"]["Transaction"], o) ]
			end
			
			order = Order.find_or_initialize_by_ebay_order_identifier(o["OrderID"])
			order.items << items
			customer.orders << order
			customer.save!
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
		
		def process_transaction(t, o)		
			item_id = t["Item"]["ItemID"]

			item = @ebay_api.request(:GetItem, :ItemID => item_id, :DetailLevel => "ItemReturnDescription")

			quantity = item["GetItemResponse"]["Item"]["SellingStatus"]["QuantitySold"]
			
			matches = item["GetItemResponse"]["Item"]["Description"].scan(/\[\[CASAMIENTO_SKU::(.*)\]\]/).flatten

			unless matches.first.nil?
				sub_quantity, product_id = matches.first.split('-')
			end
			product = Product.find(product_id)

			if order = Order.find_by_ebay_order_identifier(t["OrderLineItemID"])
				@orders_to_be_deleted << order.id
			end
			
			item = Item.find_or_initialize_by_ebay_order_line_item_token(t["OrderLineItemID"])
			item.quantity_ordered = quantity.to_i * sub_quantity.to_i
			item.product = product
			item.price = 20
			item
		end
	
	end
end

Casamiento::ImportOrders.new
