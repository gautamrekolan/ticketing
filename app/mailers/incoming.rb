class Incoming < ActionMailer::Base

  def receive(email)
    @attachments = []
    @email = email
    @subject = email.subject.gsub(/Re:/i, '').strip
    
    process_addresses
    process_email
    find_conversation
    
    message = @conversation.messages.build(:content => @body, :datetime => email.date, :subject => @subject, :attachments => @attachments)
    message.build_raw_email(:content => email.raw_source)

	  if @all_addresses.all? { |e| e.new_record? } && @conversation.new_record?
		  customer = Customer.new(:name => email[:from].display_names.first || email[:from].addresses.first )
	  	customer.customer_emails << @all_addresses
		  customer.conversations << @conversation
	  	customer.save!
	  	
	  elsif !@all_addresses.all? { |e| e.new_record? } && @conversation.new_record?
		  new_email_addresses = @all_addresses.select { |e| e.new_record? }
	  	existing_addresses = @all_addresses.select { |e| !e.new_record? }
		  existing_addresses.first.customer.conversations << @conversation
	  	existing_addresses.first.customer.customer_emails << new_email_addresses		
		
	  elsif !@conversation.new_record? && @all_addresses.all? { |e| e.new_record? }
		  @conversation.customer.customer_emails << @all_addresses
	  end
    
    message.reply_to_addresses << @reply_to_addresses unless @reply_to_addresses.nil?
    message.from_addresses << @from_addresses
  end
  
  def process_email
  	if @email.multipart?
	  	process_body
		  process_multipart(@email)
	  else
		  @body = @email.body.decoded.force_encoding(@email.charset).encode!('utf-8')
	  end
  end
  
  def process_addresses
    @from_addresses = @email[:from].addresses.map do |address|
		  CustomerEmail.find_or_initialize_by_address(address)
	  end

    unless @email[:reply_to].nil? 
      @reply_to_addresses = @email[:reply_to].addresses.map do |address|
        CustomerEmail.find_or_initialize_by_address(address)
      end
    end

    if @reply_to_addresses.nil?
      @all_addresses = @from_addresses
    else
      @all_addresses = @reply_to_addresses + @from_addresses
    end 
  end

	def find_conversation
    if @body =~ /CASAMIENTO\[(.*)\]/
			conversation_id = $1
	  else
	    related = Message.find_all_by_subject(@subject)	 
	    related.each do |r|
	      addresses = r.all_addresses + @all_addresses unless related.blank?
	      if addresses && addresses.uniq!
	        conversation_id = r.conversation_id
	        break
	      end
	    end
		end    

		begin
	    @conversation = Conversation.find(conversation_id) 
 	  rescue ActiveRecord::RecordNotFound
	    @conversation = Conversation.new
   	end	

	end

	def process_body
    body = @email.text_part || @email.html_part			
		@body = body.decoded.force_encoding(body.charset).encode!('utf-8')
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
	
	def process_multipart(part)
		if part.multipart?
			process_parts(part.parts)
		else
			raise Exception, "Unknown content_type: #{mail.content_type}"
		end
	end

end
