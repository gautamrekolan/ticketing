class InvoiceFormatter
	def initialize(orders)
		@orders = orders
		@builder = Builder::XmlMarkup.new(:indent => 2)
		@result = @builder.instruct!
	end
	
	def define_variables
		57.times { |n| @builder.variable("varName" => "Variable#{n}", "trait" => "textcontent") }
	end
	
	def define_orders(order)
		@builder.tag!("Variable0") do 
		  @builder.p order.customer_address.name
		  @builder.p order.customer_address.company
		  @builder.p order.customer_address.address_1
		  @builder.p order.customer_address.address_2
		  @builder.p order.customer_address.town
		  @builder.p order.customer_address.county
		  @builder.p order.customer_address.postcode
		end
		@builder.tag!("Variable1") do 
		  @builder.p order.customer_address.name
		  @builder.p order.customer_address.company
		  @builder.p order.customer_address.address_1
		  @builder.p order.customer_address.address_2
		  @builder.p order.customer_address.town
		  @builder.p order.customer_address.county
		  @builder.p order.customer_address.postcode
		end
		@builder.tag!("Variable2") do 
		  @builder.p order.customer_address.name
		  @builder.p order.customer_address.company
		  @builder.p order.customer_address.address_1
		  @builder.p order.customer_address.address_2
		  @builder.p order.customer_address.town
		  @builder.p order.customer_address.county
		  @builder.p order.customer_address.postcode
		end
		@builder.Variable3 { @builder.p order.id }
		@builder.Variable4 { @builder.p order.customer_id }
		@builder.Variable5 { @builder.p order.created_at }
		count = 0
		init = 6
		order.items.each do |item|
		  @builder.tag!("Variable#{init}") { @builder.p item.quantity_ordered }
		  @builder.tag!("Variable#{init + 1}") { @builder.p item.product_id }
		  @builder.tag!("Variable#{init + 2}")  { @builder.p item.product.description }
		  @builder.tag!("Variable#{init + 3}")  { @builder.p item.price }
		  @builder.tag!("Variable#{init + 4}")  { @builder.p item.price * item.quantity_ordered }
		  init = init + 5
		end
		remaining = 56 - init
		remaining.times do |n| 
		  @builder.tag!("Variable#{init}", " ")
		  init = init + 1
		end
		
		@builder.Variable56 { @builder.p "32.99" }
	end
	
	def define_dataset
		@orders.each_with_index do |order, index|
			@builder.tag!("v:sampleDataSet", "dataSetName" => "#{index}") { define_orders(order) }				
		end				
	end
	
	def output				
		@builder.svg do
			@builder.variableSets do
				@builder.variableSet("locked" => "none") do
					@builder.variables do
						define_variables
					end
					@builder.tag!("v:sampleDataSets", "xmlns:v"=> "casamiento") do
						define_dataset
					end	
				end
			end
		end
		@result				
	end
end
