require 'test_helper'

class EbayMessageMailFilterTest < ActiveSupport::TestCase

  test "the truth" do
    assert true
  end
  
  def setup
    @mail = Mail.read(Rails.root.to_s + '/test/fixtures/incoming/ebay_message.eml')
    @user = { :GetUserResponse => { :User => { :Email => "david.p@dizzy.com", :EIASToken => "anothernightanotherday" } } }
  end

  def create_customer_with_conversation!
    @get_user_response = build_xml_from_hash(@user)
    stub_request(:post, "https://api.ebay.com/ws/api.dll").to_return(:body => @get_user_response)
    customer = Factory.create(:customer, :eias_token => "anothernightanotherday")
    conversation = customer.conversations.create!
    @message = conversation.messages.create!(:subject => "An ostrich landed on Venus today", :datetime => Time.now)
    email = customer.customer_emails.create!(:address => "julie.hoolie@yahoo.co.uk")
    email2 = customer.customer_emails.create!(:address => "melanie.chisholm@doogle.com")
    email3 = customer.customer_emails.create!(:address => "patbriers@yoohoo.com")
    @message.from_addresses << email
    @message.from_addresses << email2
    @message.reply_to_addresses << email3  
  end

  def test_link_messages_by_subject_where_message_has_same_subject_and_matching_eias_token
    create_customer_with_conversation!    
    @mail.subject = "Re: re:   An ostrich landed on Venus today     "
    @mail.from = '"eBay Member: casamiento-wedding-stationery" <david.jameson@dizzy.co.uk>' 
    assert_differences [ ['Customer.count', 0], ['Conversation.count', 0], ['Message.count', 1] ] do
      Incoming.receive(@mail.to_s)
    end
    assert_equal @message.conversation, Message.all.last.conversation
  end
  
  def test_link_messages_by_subject_where_message_has_same_subject_and_matching_email_addresses_but_different_eias_token
    @user[:GetUserResponse][:User][:EIASToken] = "bloobloo"
    create_customer_with_conversation!
    @mail.subject = "Re: re: RE:  An ostrich landed on Venus today"
    @mail.from = '"eBay Member: casamiento-wedding-stationery" <melanie.chisholm@doogle.com>'
    assert_differences [ [ 'Customer.count', 0], ['Conversation.count', 0], ['Message.count', 1] ] do
      Incoming.receive(@mail.to_s)
    end
  end
  
  def test_link_message_to_existing_customer_if_eias_token_matches_and_start_new_conversation_if_no_subject_matches
    create_customer_with_conversation!
    @mail.subject = "Re: RE: RE: RE: A new conversation is beginning"
    @mail.from = '"eBay Member: casamientoweddingstationery" <patbriers@yahoo.com>'
    assert_differences [ [ 'Customer.count', 0], ['Conversation.count', 1], ['Message.count', 1], [ 'CustomerEmail.count', 2 ] ] do
      Incoming.receive(@mail.to_s)
    end
  end
  
end
