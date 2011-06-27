#Mail.defaults do
#  retriever_method :pop3, { :address    => "pop.gmail.com",
#						  :port       => 995,
#						  :user_name  => 'checkout.charlie.1980@gmail.com',
#						  :password   => '12thjuly1995',
#						  :enable_ssl => true }
#end
#@results = Mail.all
require 'pp'

alternative_1 = Mail.read("test/fixtures/emails/multipart_mixed.eml")
@ticket_id = ""
@body = ""
@attachments = []
def process_body(mail)

	@body = mail.body.decoded
	if @body =~ /CASAMIENTO\[(.*)\]/
		@ticket_id = $1
	end
end
def process_multipart_alternative(parts)
	parts.each do |p|
		if p.content_type =~ /plain/
			process_body(p)
			break
		elsif p.content_type =~ /html/
			process_body(p)
			break
		end
	end
end

def process_parts(parts)
	parts.each do |p|
		if p.multipart?
			process_multipart(p)
		elsif p.content_disposition =~ /attachment/
			@attachments << p.content_type
		else
			process_body(p)
		end
	end
end	

def process_multipart(mail)
	if mail.content_type =~ /alternative/
		process_multipart_alternative(mail.parts)
	elsif mail.multipart?
		process_parts(mail.parts)
	else
		puts mail.content_type
	end
end


def process_mail(mail)
	if mail.multipart?
		process_multipart(mail)
	else
		process_body(mail)
	end	
end

@from = alternative_1.from

process_mail(alternative_1)
# No ticket id
@customer_email = CustomerEmail.find_by_address(@from)	
begin
@conversation = Conversation.find(@ticket_id)
rescue ActiveRecord::RecordNotFound
@conversation = nil
end

if !@conversation.nil?
puts "0"	
elsif @conversation.nil? && !@customer_email.nil?
puts "1"
	@conversation = Conversation.new
	@customer_email.customer.conversations << @conversation
elsif @conversation.nil? && @customer_email.nil?
puts "2"
	@conversation = Conversation.new
	@customer_email = CustomerEmail.new(:address => @from)
	@customer = Customer.new(:name => alternative_1[:from].display_names)
	@customer.customer_emails << @customer_email
	@customer.conversations << @conversation
end
pp @customer
puts @body
puts @attachments