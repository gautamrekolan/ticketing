xml.instruct!
xml.svg do
	xml.variableSets do
		xml.variableSet("locked" => "none") do
			xml.variables do
				57.times { |n| xml.variable("varName" => "Variable#{n}", "trait" => "textcontent") }
			end
			xml.tag!("v:sampleDataSets", "xmlns:v"=> "casamiento") do
			  xml << (render :collection => @orders, :partial => "invoices/order")
			end
		end
	end
end
