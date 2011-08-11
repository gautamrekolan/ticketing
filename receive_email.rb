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
	customer_email = CustomerEmail.find_or_initialize_by_address(email.from)
rescue ActiveRecord::RecordNotFound
	conversation = nil
end

if conversation.nil? && !customer_email.nil? && !customer_email.customer.nil?
	conversation = Conversation.new
	customer_email.customer.conversations << conversation	
elsif conversation.nil? && customer_email.nil?
	conversation = Conversation.new
	customer_email = CustomerEmail.new(:address => email.from)
	customer = Customer.new(:name => alternative_1[:from].display_names)
	customer.customer_emails << customer_email
	customer.conversations << conversation
	customer.save!
end

conversation.messages << Message.new(:content => email.body)
pp customer
pp customer.conversations
