class Incoming < ActionMailer::Base
require 'pp'
  def receive(email)
    @attachments = []
    @email = email
    @subject = email.subject.gsub(/Re:/i, '').strip unless email.subject.nil?
    @subject = "NO SUBJECT" if @subject.nil? || @subject.blank?
    @all_addresses = @email[:from].addresses + @email[:reply_to].addresses unless @email[:reply_to].nil? || @email[:from].nil?
	  @all_addresses ||= @email[:from].addresses unless @email[:from].nil?
	  begin # WARNING this will rescue from any errors so errors will fail silently. Remove begin/rescue to debug!
	   process
	  rescue Exception => error
	    RawUnimportedEmail.create!(:content => email.raw_source, :error => error.message)
	  end
  end
  
  def process  
    process_email
    process_filters
    begin 
      find_conversation
    rescue ActiveRecord::RecordNotFound
	    find_conversation_by_subject
   	end	
   	
   	handle_empty_conversations   	   
    process_addresses

    message = @conversation.messages.build(:content => @body, :datetime => @email.date, :subject => @subject, :attachments => @attachments)

    message.from_addresses = @from_addresses
    message.reply_to_addresses = @reply_to_addresses unless @reply_to_addresses.nil?
    message.build_raw_email(:content => @email.raw_source)
    @conversation.customer.save! if @conversation.customer && @conversation.customer.new_record?
    @conversation.save!
  
  end
  
  def process_filters
    
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
     
      @from_addresses = CustomerEmail.where(:address => @email[:from].addresses.uniq)
      addresses_to_create = @email[:from].addresses.uniq - @from_addresses.map(&:address)
      @from_addresses = @from_addresses + addresses_to_create.collect { |a| CustomerEmail.create!(:address => a, :customer => @customer) }

    if @email[:reply_to]
      @reply_to_addresses = CustomerEmail.where(:address => @email[:reply_to].addresses)
      addresses_to_create = @email[:reply_to].addresses - @reply_to_addresses.map(&:address)
      @reply_to_addresses = @reply_to_addresses + addresses_to_create.collect { |a| CustomerEmail.create!(:address => a, :customer => @customer) }
    end

  end

	def find_conversation
    if @body =~ /CASAMIENTO\[(.*)\]/ # find on ticket
			conversation_id = $1
			@conversation = Conversation.find(conversation_id) 
	  else # on subject
	    find_conversation_by_subject
		end
	end
	
	def find_conversation_by_subject
	
	  #@conversation ||= Conversation.includes(:customer, :messages => [ :from_addresses, :reply_to_addresses ]).where("customer_emails.address in(?) or reply_to_addresses_messages.address in (?)", @all_addresses, @all_addresses).where(:messages => { :subject => @subject } ).limit(1).first
	
	  @conversation ||= Conversation.includes(:messages, :ebay_messages, :customer => :customer_emails).where("customer_emails.address in(?) and (messages.subject = ? or ebay_messages.subject = ?)", @all_addresses, @subject, @subject).limit(1).first
	end
	
	def handle_empty_conversations
	if @conversation.blank?
		  @customer = Customer.joins(:customer_emails).where(:customer_emails => { :address => @all_addresses }).first

      if @customer.blank?
        @customer = Customer.new(:name => @email[:from].display_names.first || @email[:from].addresses.first)
      end
		  @conversation = @customer.conversations.build
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
