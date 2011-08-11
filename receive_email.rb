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

alternative_1 = Mail.read("test/fixtures/incoming/gmail.eml")
email = EmailParser.new(alternative_1)

if !email.ticket_id.blank?

	begin
		conversation = Conversation.find(email.ticket_id) 
	rescue ActiveRecord::RecordNotFound
		conversation = Conversation.new
	end
else
	conversation = Conversation.new
end

message = Message.new(:content => email.body)
email.attachments.each do |a|
	message.attachments.build(:content_type => a.mime_type, :content => a.decoded, :filename => a.filename)
end

conversation.messages << message

from_addresses = email.from.map do |address|
	CustomerEmail.find_or_initialize_by_address(address)
end

if from_addresses.all? { |e| e.new_record? } && conversation.new_record?
	customer = Customer.new(:name => email.from.first)
	customer.customer_emails << from_addresses
	customer.conversations << conversation
	customer.save!
elsif !from_addresses.all? { |e| e.new_record? } && conversation.new_record?
	customer_email.customer.conversations << conversation
elsif !conversation.new_record? && from_addresses.all? { |e| e.new_record? }
	conversation.customer.customer_emails << from_addresses
end

