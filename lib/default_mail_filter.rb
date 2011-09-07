class DefaultMailFilter

  def initialize(email)
    @email = email
    
    @customer_attributes = {}
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
    update_customer

    message = @conversation.messages.build(:content => content, :datetime => @email.date, :subject => sanitized_subject, :from_addresses => @from_addresses)

    message.reply_to_addresses = @reply_to_addresses unless @reply_to_addresses.nil?
    message.build_raw_email(:content => @email.raw_source)
    @conversation.customer.save! if @conversation.customer.new_record? || @conversation.customer.changed?
    @conversation.save!
  end
  
  def update_customer
    @customer_attributes.each do |k,v|
      @conversation.customer.__send__(k.to_s + "=", v)
    end
  end
  
  def addresses_to_match
    @all_addresses = from_addresses_in_email + reply_to_addresses_in_email unless reply_to_addresses_in_email.nil? || from_addresses_in_email.nil?
	  @all_addresses ||= from_addresses_in_email unless from_addresses_in_email.nil?
  end
  
  def sanitized_subject
    sanitized_subject = @email.subject.gsub(/Re:/i, '').strip unless @email.subject.blank?
    if sanitized_subject.nil? || sanitized_subject.blank?
      @subject = "NO SUBJECT"
    else
      @subject = sanitized_subject
    end 
  end
    
  def subject_to_match
    sanitized_subject
  end  
    
  def reply_to_addresses_in_email
	  @email[:reply_to].addresses.uniq unless @email[:reply_to].nil?
  end
  
  def from_addresses_in_email
	  @email[:from].addresses.uniq unless @email[:from].nil?
  end
  
  def display_name
    display_names = @email[:from].display_names unless @email[:from].nil?
    display_names.first || from_addresses_in_email.first
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
    @conversation ||= Conversation.with_matching_subject(subject_to_match).with_matching_email_addresses_or_eias_token(addresses_to_match, eias_token).limit(1).first
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
	
  def content
   if @email.multipart?
      new_body = @email.text_part || @email.html_part
		  return new_body.decoded.force_encoding(new_body.charset).encode!('utf-8')
		else
		  return @email.body.decoded.force_encoding(@email.body.charset).encode!('utf-8')
		end  
  end


end
