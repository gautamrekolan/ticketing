
module Ebay
	module Requests				

		class GetOrders < Base
			include XML::Mapping
			root_element_name "GetOrdersRequest"	
			text_node :number_of_days, "NumberOfDays", :optional => true
			text_node :create_time_from, "CreateTimeFrom", :optional => true
			text_node :create_time_to, "CreateTimeTo", :optional => true
		end
	end
end
