class DefaultMailFilter

  def initialize(email)
    @email = email
  end
  
  def filter!
    begin # WARNING this will rescue from any errors so errors will fail silently. Remove begin/rescue to debug!
	    process!
	  rescue Exception => error
	    RawUnimportedEmail.create!(:content => @email.raw_source, :error => error.message)
	  end
  end
  
  def process! 
	  find_conversation
   	handle_empty_conversations
    process_addresses
    
    message = @conversation.messages.build(:content => @email.body, :datetime => @email.date, :subject => @email.subject, :attachments => @email.attachments, :from_addresses => @from_addresses)

    message.reply_to_addresses = @reply_to_addresses unless @reply_to_addresses.nil?
    message.build_raw_email(:content => @email.raw_source)
    @conversation.customer.save! if @conversation.customer.new_record?
    @conversation.save!
  end
  
  def addresses_to_match
    @email.all_addresses
  end
    
  def subject_to_match
    @email.subject
  end  
    
  def reply_to_addresses_in_email
    @email.reply_to_addresses
  end
  
  def from_addresses_in_email
    @email.from_addresses
  end
  
  def display_name
    @email.display_names.first || @email.from_addresses.first
  end
  
  def ebay_user_id 
  end
  
  def eias_token 
  end
    
  def from_addresses_in_database
    @from_addresses_in_database ||= CustomerEmail.where(:address => from_addresses_in_email)
  end
  
  def reply_to_addresses_in_database
    @reply_to_addresses_in_database ||= CustomerEmail.where(:address => reply_to_addresses_in_email)
  end
  
  def process_addresses      
      addresses_to_create = from_addresses_in_email - from_addresses_in_database.map(&:address)
      @from_addresses = from_addresses_in_database + addresses_to_create.collect { |a| CustomerEmail.create!(:address => a, :customer => @customer) }

    if reply_to_addresses_in_email
      addresses_to_create = reply_to_addresses_in_email - reply_to_addresses_in_database.map(&:address)
      @reply_to_addresses = reply_to_addresses_in_database + addresses_to_create.collect { |a| CustomerEmail.create!(:address => a, :customer => @customer) }
    end
  end
  
  def find_conversation
    @conversation ||= Conversation.with_matching_subject(subject_to_match).with_matching_email_addresses(addresses_to_match).limit(1).first
  end
  
  def find_or_create_customer
    if @customer.blank?
      @customer = Customer.where_email_addresses_match(addresses_to_match).limit(1).first
      @customer = Customer.new(:name => display_name, :ebay_user_id => ebay_user_id, :eias_token => eias_token) if @customer.blank?
    end
  end
	
	def handle_empty_conversations
	  if @conversation.blank?
	    find_or_create_customer
	    @conversation = @customer.conversations.build
	  end
	end

end
