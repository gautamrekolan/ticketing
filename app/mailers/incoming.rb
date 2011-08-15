
class Incoming < ActionMailer::Base
  default :from => "from@example.com"

  def receive(email)
    @attachments = []
    process_email(email)
		 
    message = Message.new(:content => @body, :datetime => email.date)

    @conversation.messages << message

    message.attachments = @attachments

	  from_addresses = email[:from].addresses.map do |address|
		  CustomerEmail.find_or_initialize_by_address(address)
	  end

    unless email[:reply_to].nil? 
      reply_to_addresses = email[:reply_to].addresses.map do |address|
        CustomerEmail.find_or_initialize_by_address(address)
      end
    end

    if reply_to_addresses.nil?
      all_addresses = from_addresses
    else
      all_addresses = reply_to_addresses + from_addresses
    end 

	  if all_addresses.all? { |e| e.new_record? } && @conversation.new_record?
		  customer = Customer.new(:name => email[:from].display_names.first || email[:from].addresses.first )
	  	customer.customer_emails << all_addresses
		  customer.conversations << @conversation
	  	customer.save!
	  elsif !all_addresses.all? { |e| e.new_record? } && @conversation.new_record?
		  new_email_addresses = all_addresses.select { |e| e.new_record? }
	  	existing_addresses = all_addresses.select { |e| !e.new_record? }
		  existing_addresses.first.customer.conversations << @conversation
	  	existing_addresses.first.customer.customer_emails << new_email_addresses		
		
	  elsif !@conversation.new_record? && all_addresses.all? { |e| e.new_record? }
		  @conversation.customer.customer_emails << all_addresses
	  end
    
    message.reply_to_addresses << reply_to_addresses unless reply_to_addresses.nil?
    message.from_addresses << from_addresses

  end
  
  def process_email(email) 
  	if email.multipart?
	  	process_body(email)
		  process_multipart(email)
	  else
		  @body = email.body.decoded
	  	decode(email.charset)
	  end
  end

	def process_multipart(mail)
		if mail.multipart?
			process_parts(mail.parts)
		else
			raise Exception, "Unknown content_type: #{mail.content_type}"
		end
	end

	def decode(charset)	
puts "--------------------------------------------------------------------------"
puts charset
		if @body.encoding.to_s == "ASCII-8BIT" || @body.encoding.to_s == "US-ASCII"
			@body.force_encoding(charset).encode!('utf-8')
		end	
  puts @body.encoding

		@body.strip!
		@body.gsub!("\r\n", "\n")

    if @body =~ /CASAMIENTO\[(.*)\]/
			conversation_id = $1
		end    

		begin
	    @conversation = Conversation.find(conversation_igid) 
 	  rescue ActiveRecord::RecordNotFound
	    @conversation = Conversation.new
   	end	

	end

	def process_body(mail)
    mail = mail.text_part || mail.html_part
			charset = mail.charset
			@body = mail.decoded 
puts charset
		decode(charset)	
	end
	
	def process_parts(parts)
		parts.each do |p|
			if p.multipart?
				process_multipart(p)
			elsif p.content_disposition =~ /attachment/
				@attachments << Attachment.new(:content_type => p.mime_type, :content => p.decoded, :filename => p.filename)
			
			end
		end
	end	

end
