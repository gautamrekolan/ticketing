require 'test_helper'

class EmailImportTest < ActiveSupport::TestCase

  test "the truth" do
    assert true
  end
  
  def setup
    @mail = Mail.new do
      from     'david.pettifer@dizzy.co.uk'
      to       'david.p@casamiento-cards.co.uk'
      subject  "Subject line"
      body     "Here is the body"
    end
  end

	def test_create_new_conversation_and_add_to_existing_customer_with_matching_email_address
		customer = FactoryGirl.create(:customer, :name => "David Pettifer", :customer_emails => [ CustomerEmail.new(:address => "david.pettifer@dizzy.co.uk")])
		assert_differences [ ["Message.count", 1], ["Conversation.count", 1], ["Customer.count", 0 ] ] do
		  Incoming.receive(@mail.to_s)
		end
		assert_equal "David Pettifer", Conversation.first.customer.name    
	end

  def test_create_new_conversation_and_create_new_customer_without_matching_email_address
    assert_difference ['Customer.count', 'CustomerEmail.count'], 1 do
      Incoming.receive(@mail.to_s)
    end
    assert_equal "david.pettifer@dizzy.co.uk", Customer.first.name
  end

  def test_create_conversation_and_create_customer_with_invalid_conversation_id
    assert_difference ["Customer.count", "Conversation.count", "Message.count"], 1 do
      Incoming.receive(@mail.to_s)    
    end
  end

  #def test_store_large_email_correctly
  #  mail = Mail.read(Rails.root.to_s + "/test/fixtures/incoming/long_email_with_attachment.eml")
	#  raw_source = mail.raw_source
  #  Incoming.receive(mail.raw_source)
  #  assert_equal raw_source, RawEmail.first.content, "Not identical"
  #end 
  
  def test_message_correctly_populated
    assert_difference 'Message.count', 1 do
      Incoming.receive(@mail.to_s)
    end
    message = Message.first
    assert_equal "Subject line", message.subject
    assert_equal "Here is the body", message.content
  end
  
  def test_from_addresses_added_correctly
    @mail.from = ["david.p@dizzy.co.uk", "rebelcoo7@hotmail.com", "Christine Hannam <christine.hannam@yahoo.com>"]
    Incoming.receive(@mail.to_s)
    assert_equal ["david.p@dizzy.co.uk", "rebelcoo7@hotmail.com", "christine.hannam@yahoo.com"], CustomerEmail.all.map(&:address)
  end
  
  def test_reply_to_addresses_added_correctly
    @mail.reply_to = ["jezabelle.bloom@lewis.com", "partnerconnect@partnerconnect.co.uk", "jamie.oliver@cooks.de"]
    Incoming.receive(@mail.to_s)
    assert_equal ["jezabelle.bloom@lewis.com", "partnerconnect@partnerconnect.co.uk", "jamie.oliver@cooks.de", "david.pettifer@dizzy.co.uk"], CustomerEmail.all.map(&:address)
  end
  
  def test_addresses_not_duplicated
    @mail.reply_to = ["david.pettifer@dizzy.co.uk", "david.pettifer@dizzy.co.uk"]
    @mail.from = [ "david.pettifer@dizzy.co.uk", "David Pettifer <david.pettifer@dizzy.co.uk>" ]

    Incoming.receive(@mail.to_s)
    customer_emails = CustomerEmail.where(:address => "david.pettifer@dizzy.co.uk").count
    assert_equal 1, customer_emails
  end
  
  def test_conversation_subject_is_valid
    Incoming.receive(@mail.to_s)
    conversation = Conversation.first
    assert_equal "Subject line", conversation.subject
  end
  
  def test_empty_message_subject
    @mail.subject = ""
    Incoming.receive(@mail.to_s)
    conversation = Conversation.first
    assert_equal "NO SUBJECT", conversation.subject
  end 
  
  def test_link_message_with_empty_subject_to_conversation
    customer = Factory.create(:customer)
    conversation = customer.conversations.create
    message = conversation.messages.create(:subject => "NO SUBJECT")
    message.from_addresses << CustomerEmail.new(:address => "jerry.yang@yahoo.com")

    @mail.subject = ""
    @mail.from = "jerry.yang@yahoo.com"
    Incoming.receive(@mail.to_s)

    assert_equal conversation, message.conversation
  end
  
  def test_link_messages_by_subject_where_message_has_same_subject_and_matching_email_addresses
    customer = Factory.create(:customer)
    conversation = customer.conversations.create!
    message = conversation.messages.create!(:subject => "An elephant landed on Mars today", :datetime => Time.now)
    email = customer.customer_emails.create!(:address => "julie.hoolie@yahoo.co.uk")
    message.from_addresses << email
   
    @mail.subject = "RE: re: An elephant landed on Mars today"
    @mail.from = "julie.hoolie@yahoo.co.uk"
    assert_no_difference "Conversation.count" do
      Incoming.receive(@mail.to_s)
    end
    message = Message.all[1]
    assert_equal conversation, message.conversation
  end
  
  def test_do_not_link_messages_by_subject_where_subject_exists_but_emails_do_not_match
    customer = Factory.create(:customer)
    conversation = customer.conversations.create!
    message = conversation.messages.create!(:subject => "Because I made a stupid mistake...", :datetime => Time.now)
    email = customer.customer_emails.create!(:address => "lewis.mcnamara@waitrose.com")
    message.from_addresses << email
    
    @mail.subject = "Because I made a stupid mistake..."
    @mail.from = "lewis@waitrose.com"
    
    assert_difference "Conversation.count" do
      Incoming.receive(@mail.to_s)
    end
    new_message = Message.last
    assert_equal "lewis@waitrose.com", new_message.conversation.customer.name
    assert_not_equal customer, new_message.conversation.customer
    assert_not_equal conversation, new_message.conversation
  end
  
  def test_strip_subject_of_re_and_whitespace
    @mail.subject = "  RE: re: re: Here   is the subject   line with some white space     \t\t"
    Incoming.receive(@mail.to_s)
    message = Message.first
    assert_equal "Here is the subject line with some white space", message.subject
  end
  
  def test_adds_to_existing_conversation_with_ebay_message
    customer = FactoryGirl.create(:customer, :name => "David Pettifer", :customer_emails => [ CustomerEmail.new(:address => "david.pettifer@dizzy.co.uk"), CustomerEmail.new(:address => "melanie.sykes@hotmail.com") ])
    conversation = customer.conversations.create!
    ebay_message = conversation.ebay_messages.create!(:subject => "Here is another lovely subject line", :datetime => 30.days.ago, :content => "Here is the main body of the message")
    @mail.subject = "Here is another lovely subject line"
    Incoming.receive(@mail.to_s)
    
    @mail.subject = "RE: Here is another lovely subject line "
    @mail.from = "melanie.sykes@hotmail.com"
    @mail.body = "This has a different body to it"
    Incoming.receive(@mail.to_s)
  end
  
  def test_invalid_email
    mail = Mail.read(Rails.root.to_s + "/test/fixtures/incoming/invalid.eml") 
    assert_difference "RawUnimportedEmail.count" do
      Incoming.receive(mail)
    end
  end
  
  def test_z_merge_customer
    WebMock.allow_net_connect! 
    Incoming.receive(@mail.to_s)
    new_ebay_message = @mail.dup
    new_ebay_message.from = '"eBay Member: casamiento-wedding-stationery" <lewis@dizzy.co.uk>'
    Incoming.receive(new_ebay_message.to_s)
       
    new_paypal_message = @mail.dup
    new_paypal_message.from = "david.pettifer@dizzy.co.uk"
    new_paypal_message.subject = "Item no.250822959813 - Notification of an Instant Payment Received from casamiento-wedding-stationery (david.pettifer@dizzy.co.uk)"
    Incoming.receive(new_paypal_message.to_s)
    pp Message.all
    pp CustomerEmail.all
    pp Customer.all
pp Conversation.all
  end
  
end
