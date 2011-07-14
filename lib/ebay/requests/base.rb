
module Ebay
	module Requests				
		class Base
			include XML::Mapping
			include Ebay::Initializer
			
			object_node :requester_credentials, "RequesterCredentials", :class => RequesterCredentials
			
			def requester_credentials
				RequesterCredentials.new
			end
		end
		
	end
end

