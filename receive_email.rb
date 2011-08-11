#Mail.defaults do
#  retriever_method :pop3, { :address    => "pop.gmail.com",
#						  :port       => 995,
#						  :user_name  => 'checkout.charlie.1980@gmail.com',
#						  :password   => '12thjuly1995',
#						  :enable_ssl => true }
#end
#@results = Mail.all
require 'pp'
require 'email_parser'

alternative_1 = Mail.read("test/fixtures/incoming/multipart_mixed.eml")
email = EmailParser.new(alternative_1)

begin
conversation = Conversation.find(email.ticket_id) 
rescue ActiveRecord::RecordNotFound
conversation = Conversation.new
end
conversation.messages << Message.new(:content => email.body)
customer_email = CustomerEmail.find_or_initialize_by_address(email.from.first)

if customer_email.new_record? && conversation.new_record?
	customer = Customer.new(:name => email.from.first)
	customer.customer_emails << customer_email
	customer.conversations << conversation
	customer.save!
elsif !customer_email.new_record? && conversation.new_record?
	customer_email.customer.conversations << conversation
elsif !conversation.new_record? && customer_email.new_record?
	conversation.customer.customer_emails << customer_email
end
puts customer_email.address