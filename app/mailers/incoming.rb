class Incoming < ActionMailer::Base
  default :from => "from@example.com"

  def receive(email)
    @attachments = []
	  if email.multipart?
			process_multipart(email)
		else
			process_body(email)
		end	
		 
    message = Message.new(:content => @body)
    @conversation.messages << message
    message.attachments = @attachments

	  from_addresses = email.from.map do |address|
		  CustomerEmail.find_or_initialize_by_address(address)
	  end

	  if from_addresses.all? { |e| e.new_record? } && @conversation.new_record?
		  customer = Customer.new(:name => email.from.first)
	  	customer.customer_emails << from_addresses
		  customer.conversations << @conversation
	  	customer.save!
	  elsif !from_addresses.all? { |e| e.new_record? } && @conversation.new_record?
		  new_email_addresses = from_addresses.select { |e| e.new_record? }
	  	existing_addresses = from_addresses.select { |e| !e.new_record? }
		  existing_addresses.first.customer.conversations << @conversation
	  	existing_addresses.first.customer.customer_emails << new_email_addresses		
		
	  elsif !@conversation.new_record? && from_addresses.all? { |e| e.new_record? }
		  @conversation.customer.customer_emails << from_addresses
	  end
  end
  
  def start_or_find_conversation
  	  
  end
  
	def process_multipart(mail)
		if mail.content_type =~ /alternative/
			process_multipart_alternative(mail.parts)
		elsif mail.multipart?
			process_parts(mail.parts)
		else
			raise Exception, "Unknown content_type: #{mail.content_type}"
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

	def process_body(mail)
		@body = mail.body.decoded
		if @body =~ /CASAMIENTO\[(.*)\]/
			conversation_id = $1
		end
		
    begin
	    @conversation = Conversation.find(conversation_id) 
    rescue ActiveRecord::RecordNotFound
	    @conversation = Conversation.new
    end
	end
	
	def process_parts(parts)
		parts.each do |p|
			if p.multipart?
				process_multipart(p)
			elsif p.content_disposition =~ /attachment/
				@attachments << Attachment.new(:content_type => p.mime_type, :content => p.decoded, :filename => p.filename)
			else
				process_body(p)
			end
		end
	end	

end
