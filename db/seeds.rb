# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Daley', :city => cities.first)

EbayLastImportedTime.instance.update_attributes(:last_import => 29.days.ago.iso8601)

Monogram.create!(:description => "Three Squares")
Monogram.create!(:description => "Black Square")

simplicity = Theme.create(:name => "Simplicity")
day_invitation = ProductType.create(:description => "Day Invitation")
evening_invitation = ProductType.create(:description => "Evening Invitation")
invitation_envelope = ProductType.create!(:description => "Invitation Envelope", :envelope => true)
name_place = ProductType.create!(:description => "Name Place Card")
c6_envelope = ProductFormat.create(:description => "C6")

a6_flat = ProductFormat.create(:width => 105, :height => 148, :description => "A6 flat", :style => "FLAT")
tent = ProductFormat.create(:width=> 74, :height => 105, :description => "Name place card", :style => "TENT")
paper = Paper.new(:texture => "Smooth", :colour => "White", :weight => 80)
product = Product.new(:theme => simplicity, :product_format => a6_flat, :product_type => day_invitation, :paper => paper, :price => 10)
product2 = Product.new(:theme => simplicity, :product_format => a6_flat, :product_type => evening_invitation, :paper => paper, :price => 15)
product3 = Product.new(:theme => simplicity, :product_format => c6_envelope, :product_type => invitation_envelope, :paper => paper, :price => 20)
name_place = Product.new(:theme => simplicity, :product_format => tent, :product_type => name_place, :paper => paper, :price => 15)
simplicity.products << product << product2 << product3 << name_place

rose = Theme.create!(:name => "Rose")
product = Product.new(:theme => rose, :product_format => a6_flat, :product_type => day_invitation, :paper => paper, :price => 20)
product2 = Product.new(:theme => rose, :product_format => a6_flat, :product_type => evening_invitation, :paper => paper, :price => 25)
rose.products << product << product2

customer = Customer.create!(:name => "David Pettifer")
customer.orders.create(:notes => "Order notes here!")
address1 = customer.customer_emails.create(:address => "david.pettifer@dizzy.co.uk")
address2 = customer.customer_emails.create(:address => "happyhele@gmail.com")
address3 = customer.customer_emails.create(:address => "davinaj3000@yahoo.com")
address4 = customer.customer_emails.create(:address => "david.p@casamiento-cards.co.uk")
address5 = customer.customer_emails.create(:address => "rebelcoo7@hotmail.com")
conversation = customer.conversations.create
message = conversation.messages.create(:subject => "This is the first subject!")
message.from_addresses << [ address1, address2, address3 ]
message.reply_to_addresses << [ address4, address5 ]
customer = Customer.create!(:name => "Christine Hannam")
address6 = customer.customer_emails.create(:address => "christine.hannam@yahoo.com")
address7 = customer.customer_emails.create(:address => "julie.hannam@yahoo.com")
address8 = customer.customer_emails.create(:address => "wally.hannam@yahoo.com")
conversation = customer.conversations.create
message = conversation.messages.create(:subject => "This is the Hannam email")
message.from_addresses << [ address6 ]
message.reply_to_addresses << [ address7, address8 ]

customer_address = CustomerAddress.create(:customer => customer, :name => "Shirley Pettifer", :address_1 => "22 Brook Road", :town => "South Benfleet", :county => "Essex", :country => "United Kingdom", :postcode => "SS7 5PJ")
order = Order.create(:customer => customer, :customer_address => customer_address)
order.items.build(:product => product, :quantity_ordered => 30, :price => 5)
order.items.build(:product => product3, :quantity_ordered => 25, :price => 10)
order.items.build(:product => name_place, :quantity_ordered => 15, :price => 15)

order.save!


