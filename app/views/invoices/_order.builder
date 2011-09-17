xml.tag!("v:sampleDataSet", "dataSetName" => "#{order_counter}") do
  xml.tag!("Variable0") do 
   xml << (render :object => order.customer_address, :partial => "invoices/customer_address")
  end
  xml.tag!("Variable1") do 
     xml << (render :object => order.customer_address, :partial => "invoices/customer_address")
  end
  xml.tag!("Variable2") do 
     xml << (render :object => order.customer_address, :partial => "invoices/customer_address")
  end
  xml.Variable3 { xml.p order.id }
  xml.Variable4 { xml.p order.customer_id }
  xml.Variable5 { xml.p order.created_at }
  count = 0
  init = 6
  order.items.each do |item|
    xml.tag!("Variable#{init}") { xml.p item.quantity_ordered }
    xml.tag!("Variable#{init + 1}") { xml.p item.product_id }
    xml.tag!("Variable#{init + 2}")  { xml.p item.product.description }
    xml.tag!("Variable#{init + 3}")  { xml.p item.price }
    xml.tag!("Variable#{init + 4}")  { xml.p item.price * item.quantity_ordered }
    init = init + 5
  end
  remaining = 56 - 6 -(order.items.count * 5)
  remaining.times do |n| 
    xml.tag!("Variable#{init}", " ")
    init = init + 1
  end
  xml.Variable56 { xml.p "32.99" }
end				

