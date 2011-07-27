module Ebay
	module API
		class Trading
		include ::XML::Mapping
			 XmlNs = 'urn:ebay:apis:eBLBaseComponents'
			def initialize
				@trading_url = "https://api.sandbox.ebay.com/ws/api.dll"
				#@trading_url = "https://api.ebay.com/ws/api.dll"
				#@app_name = "Casmient-178b-402d-98a6-51e19780d9a0"
				@app_name = "Casmient-2aff-4dab-9163-50f440216b96"
				#@cert_name = "c0cf2bdb-6ae9-4430-964d-16115594c412"
				@cert_name = "454dd9f0-47d0-4871-ab91-ab0038a59cd3"
				@dev_name =" c8d4d396-f869-44d9-8798-df4c2de90717"
				@compatibility_level = "723"
			end

			def headers(request_name)
				{
				'X-EBAY-API-COMPATIBILITY-LEVEL' => @compatibility_level,
				'X-EBAY-API-DEV-NAME' => '7',
				'X-EBAY-API-APP-NAME' => @app_name,
				'X-EBAY-API-CERT-NAME' => @cert_name,
				'X-EBAY-API-CALL-NAME' => request_name.to_s.demodulize,
				'X-EBAY-API-SITEID' => '3'
			  }
			end

			def request(payload, request_class)
				req = Net::HTTP.new(uri.host, uri.port)

				req.use_ssl = true
				response = req.post(uri.request_uri, payload, headers(request_class))
				
				response = Hash.from_xml(response.body)
        		response_root_element = request_class.to_s.demodulize + "Response"
				response
			end
			
			def commit(request_class, params)
				payload = request_class.new(params)

				payload = build_xml(payload)
				response = request(payload, request_class)
			end

			def get_orders(params)
				commit(Ebay::Requests::GetOrders, params)
			end		
			
			def get_item(params)
				commit(Ebay::Requests::GetItem, params)
			end

			def build_xml(request)
			   result = REXML::Document.new
				result << REXML::XMLDecl.new('1.0', 'UTF-8')
				  result << request.save_to_xml
				  result.root.add_namespace XmlNs
				  result.to_s
			end	

			private

			def uri
				@uri ||= URI.parse(@trading_url)
			end

			def build_body
			  result = REXML::Document.new
			  result << REXML::XMLDecl.new('1.0', 'UTF-8')
			  result << request.save_to_xml
			  result.root.add_namespace XmlNs
			  result.to_s
			end
		end
	end
end
