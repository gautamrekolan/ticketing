require 'test_helper'
require 'pp'

class PaypalMailFilterTest < ActiveSupport::TestCase

  test "the truth" do
    assert true
  end
  
  def setup
  WebMock.allow_net_connect! 
    @mail = Mail.read(Rails.root.to_s + '/test/fixtures/incoming/paypal.eml')
  end

	def test_subject_matches
	  paypal_filter = PayPalMailFilter.new(@mail)
	  assert_difference ['Customer.count', 'Conversation.count', 'Message.count'] do
	    paypal_filter.filter!
		end
		customer = Customer.first
		assert_equal "kaytie000", customer.ebay_user_id
		assert_equal "katieduggan@live.co.uk", CustomerEmail.first.address
		assert_equal "Katie Duggan", Customer.first.name
  end
  
  def test_added_to_existing_conversation
    @customer = Customer.create!(:name => "Katie Duggan")
    @customer.customer_emails.create!(:address => "katieduggan@live.co.uk")
    conversation = @customer.conversations.create!
    conversation.messages.create!(:subject => "Item no.250822959813 - Notification of an Instant Payment Received from kaytie000 (katieduggan@live.co.uk)", :datetime => Time.now)
    paypal_filter = PayPalMailFilter.new(@mail)
    paypal_filter.filter!
    pp Conversation.all
    pp Customer.all
    pp Message.all
      pp RawUnimportedEmail.all
    
    assert Message.all.all? { |m| m.conversation_id == 1 }
    assert_equal 1, Customer.count
    assert_equal 2, Message.count, "Message.count should be 2"
    assert_equal 1, CustomerEmail.count
    assert_equal "kaytie000", Customer.first.ebay_user_id    
  end
  
  def test_email_that_doesnt_match
    mail = Mail.read(Rails.root.to_s + '/test/fixtures/incoming/text_plain_worldpay.eml')
    paypal_filter = PayPalMailFilter.new(mail)
    assert !paypal_filter.filter!
  end
  
  def test_invalid_email_with_subject_that_matches

    mail = Mail.read(Rails.root.to_s + '/test/fixtures/incoming/text_plain_worldpay.eml')
    mail.subject = "Item no.250822959813 - Notification of an Instant Payment Received from kaytie000 (katieduggan@live.co.uk)"
    Incoming.receive(mail)
  end
  
  def test_completely_invalid_email

    mail = Mail.read(Rails.root.to_s + '/test/fixtures/incoming/invalid.eml')
    Incoming.receive(mail)
    pp RawUnimportedEmail.all
    pp Customer.all
    pp CustomerEmail.all
  end
 
  
end
