require 'pp'

class ImportEbayMessages

  def initialize
  	@ebay_api = EbayApiConnection.connection
  end
  
  def import!
    get_member_messages = @ebay_api.request(:GetMemberMessages, :MailMessageType => "All", :StartCreationTime => "2011-07-01T00:00:00Z")
    messages = get_member_messages["GetMemberMessagesResponse"]["MemberMessage"]["MemberMessageExchange"]

    messages.each do |m|
      message = ImportedEbayMessage.new(m)
      
      static_email = CustomerEmail.find_or_initialize_by_address(message.static_email) unless message.static_email.blank?
          
      if message.has_related_item?
      puts true
        user = EbayUser.new(@ebay_api.request(:GetUser, :ItemID => message.item_number, :UserID => message.ebay_user_id))         
        account_email = CustomerEmail.find_or_initialize_by_address(user.account_email) if user.has_account_email?
      else
        user = EbayUser.new(@ebay_api.request(:GetUser, :UserID => message.ebay_user_id))
      end
      conversation = find_conversation(user, message, static_email, account_email)
      puts user.account_email
      puts message.static_email
      puts message.subject
      puts "\n\n"
      if conversation.blank?
        customer = Customer.find_by_eias_token(user.eias_token)
        if customer.blank?
          customer = find_customer(message.static_email, user.account_email)
        end        
        if customer.blank?
          customer = Customer.new(:ebay_user_id => message.ebay_user_id, :name => message.ebay_user_id, :eias_token => user.eias_token)
        end
        conversation = customer.conversations.build
      end
      conversation.ebay_messages.build(:subject => message.subject, :content => message.body, :datetime => message.creation_date, :ebay_message_identifier => message.message_id, :item_number => message.item_number, :customer_email => static_email)
      conversation.save!
      conversation.customer.customer_emails << static_email if !static_email.blank? && static_email.new_record?
      conversation.customer.customer_emails << account_email if !account_email.nil? && account_email.new_record?
      conversation.customer.save!
    end
  end
  
  def find_customer(static_email, account_email)
    Customer.includes(:customer_emails).where("customer_emails.address IN (?)", [static_email, account_email]).limit(1).first
  end
  
  def find_conversation(user, message, static_email, account_email)
    Conversation.includes(:messages, :ebay_messages, :customer => :customer_emails).where("(customers.eias_token = ? and (ebay_messages.subject = ? or messages.subject = ? )) OR (customer_emails.address IN (?) AND (ebay_messages.subject = ? or messages.subject = ?))", user.eias_token, message.subject, message.subject, [static_email, account_email], message.subject, message.subject).limit(1).first
  end
    
end

class EbayApiConnection
  def self.connection
    @@connection ||= connect!
  end
  
  def self.connect!
    config = YAML::load(File.open(Rails.root.to_s + "/config/ebay_trading_api.yml"))
    config = config["production"]
    Ebay::Api::Trading.new(config["url"], config["auth_token"], config["app_name"], config["cert_name"], config["dev_name"], config["compatibility_level"].to_s)  
  end
end

class EbayTradingResponse
  def initialize(response)
    @response = response
  end
  
  def connection
    @connection ||= EbayApiConnection.connection
  end
  
end

class EbayUser < EbayTradingResponse

  def user
    @response["GetUserResponse"]["User"]
  end

  def has_account_email?
    !account_email == "Invalid Request"
  end
  
  def eias_token
    user["EIASToken"]
  end
  
  def account_email
    user["Email"]
  end
  
  def feedback_score
    user["FeedbackScore"]
  end
  
  def user_id
    user["UserID"]
  end
  
  def user_id_changed?
    user["UserIDChanged"] == "true"
  end
end

class ImportedEbayMessage < EbayTradingResponse
  
  def creation_date
    @response["CreationDate"]
  end
  
  def item
    @response["Item"]
  end
  
  def has_related_item?
    !item.nil?
  end
  
  def item_number
    item["ItemID"] unless item.nil?
  end
  
  def question
    @response["Question"]
  end  
  
  def message_id
    question["MessageID"]    
  end
    
  def subject
    question["Subject"]
  end
  
  def ebay_user_id 
    question["SenderID"]
  end
  
  def body
    question["Body"]
  end
  
  def static_email
    question["SenderEmail"] unless question["SenderEmail"] == "Invalid Request"
  end
  
end
