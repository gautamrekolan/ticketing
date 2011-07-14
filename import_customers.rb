require 'net/https'
require 'pp'
order = Ebay::API::Trading.new
cred = order.get_orders(:create_time_from => 2.hours.ago.iso8601, :create_time_to => Time.now.iso8601)
result = XmlSimple.xml_in(cred.body, 'ForceArray' => false)
go = Hash.from_xml(cred.body)
o = go["GetOrdersResponse"]["OrderArray"]["Order"]
#go["GetOrdersResponse"]["OrderArray"]["Order"].each do |o|
puts "\n\n**************************************************************************\n\n"
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
	item_id = o["TransactionArray"]["Transaction"]["Item"]["ItemID"]
	item = order.get_item(:item_id => item_id, :detail_level => "ItemReturnDescription", :include_item_specifics => "1")
item = Hash.from_xml(item.body)
pp item
	#o.each do |k,v|
#		if v.is_a?(Hash)
#			puts "\n"
#		end
#		puts "----- #{k} -----"
#		pp v
#	end
	
	#if order.new_record?		
	#	customer.orders << order
	#end

	#customer.save!
#end