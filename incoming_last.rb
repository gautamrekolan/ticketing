class Incoming < ActionMailer::Base

  def receive(email)    
	  begin # WARNING this will rescue from any errors so errors will fail silently. Remove begin/rescue to debug!
      @email = ParsedMail.new(email)
	    process!
	  rescue Exception => error
	    RawUnimportedEmail.create!(:content => @email.raw_source, :error => error.message)
	  end
  end
  
  def process! 
	  find_conversation_by_subject_and_email_addresses
   	handle_empty_conversations if @conversation.blank?
    process_addresses
    message = @conversation.messages.build(:content => @email.body, :datetime => @email.date, :subject => @email.subject, :attachments => @email.attachments, :from_addresses => @from_addresses)

    message.reply_to_addresses = @reply_to_addresses unless @reply_to_addresses.nil?
    message.build_raw_email(:content => @email.raw_source)
    @conversation.customer.save! if @conversation.customer.new_record?
    @conversation.save!
  end
  
  def process_addresses      
      @from_addresses = CustomerEmail.where(:address => @email.from_addresses)
      addresses_to_create = @email.from_addresses - @from_addresses.map(&:address)
      @from_addresses = @from_addresses + addresses_to_create.collect { |a| CustomerEmail.create!(:address => a, :customer => @customer) }

    if @email.reply_to_addresses
      @reply_to_addresses = CustomerEmail.where(:address => @email.reply_to_addresses)
      addresses_to_create = @email.reply_to_addresses - @reply_to_addresses.map(&:address)
      @reply_to_addresses = @reply_to_addresses + addresses_to_create.collect { |a| CustomerEmail.create!(:address => a, :customer => @customer) }
    end

  end

	def find_conversation_by_subject_and_email_addresses
	  @conversation ||= Conversation.with_matching_subject(@email.subject).with_matching_email_addresses(@email.all_addresses).limit(1).first
	end
	
	def handle_empty_conversations
	  @customer = Customer.where_email_addresses_match(@email.all_addresses).limit(1).first
    @customer = Customer.new(:name => @email.display_names.first || @email.from_addresses.first) if @customer.blank?
	  @conversation = @customer.conversations.build
	end

end
