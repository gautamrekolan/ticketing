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
	end

	factory :theme do
		name
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