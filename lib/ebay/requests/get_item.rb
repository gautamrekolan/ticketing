
module Ebay
	module Requests				

		class GetItem < Base
			include XML::Mapping
			root_element_name "GetItemRequest"	
			text_node :item_id, "ItemID", :optional => true
			text_node :detail_level, "DetailLevel", :optional => true
			text_node :include_item_specifics, "IncludeItemSpecifics", :optional => true
		end
	end
end
