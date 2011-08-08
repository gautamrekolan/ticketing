FactoryGirl.define do
  sequence :name do |n|
	"Simplicity #{n}"
  end
end

FactoryGirl.define do 

	factory :customer do
		name "David Pettifer"
		ebay_user_id "mister-dizzy"
		eias_token "abcdefghijklmnopqrstuvwxyz"
		customer_addresses { |a| [a.association(:customer_address)] }
		customer_emails { |e| [ e.association(:customer_email) ] }
	end
	
	factory :customer_email do 
		address "david.p@dizzy.co.uk"
	end
	
	factory :customer_address do
		name "David Pettifer"
		company "Dizzy New Media Ltd"
		address_1 "40 Grange Road"
		town "Strood"
		county "Kent"
		country "United Kingdom"
		postcode "ME2 4DA"
	end
	
	factory :theme do
		name
	end
	
	factory :item do
		product
		price 99
		quantity_ordered 100
		quantity_despatched 0
	end
	
	factory :order do
		monogram
		customer
		customer_address
		items { |items| [ items.association(:item), items.association(:item) ] }
		notes "These are some notes about the order from a customer"
	end
	
	factory :monogram do
		description "Three Squares"
	end
	
	factory :paper do
	 weight "280"
		colour "White"
		texture "Smooth"
	end
	
	factory :product_type do 
		description "Day Invitation"
		envelope true
	end
	
	factory :product_format do
		description "A6"
		height 148
		width 105
		style "FOLDOUT"
	end
	
	factory :product do
		product_format
		product_type
		paper
		theme
		price 20
	end

end