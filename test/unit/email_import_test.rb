require 'test_helper'
require 'pp'

class EmailImportTest < ActiveSupport::TestCase

  test "the truth" do
    assert true
  end

  def load_email(filename)
    File.read(Rails.root.to_s + "/test/fixtures/incoming/" + filename)
  end

  def test_import_email_with_no_display_name
    Incoming.receive(load_email("conversation/no_display_name.eml"))
    
  end

	def test_receive_email_existing_customer_no_existing_conversation
		customer = FactoryGirl.create(:customer, :name => "Dreamhost", :customer_emails => [ CustomerEmail.new(:address => "lashes@noble.com")])
		Incoming.receive(load_email("conversation/conversation_1.eml"))
		assert_equal 1, Message.count
    assert_equal 1, Customer.count
		assert_equal 1, Conversation.count
		assert_equal 3, CustomerEmail.count
		assert_equal "Dreamhost", Conversation.find(1).customer.name    
	end

  def test_create_conversation_and_add_to_new_customer_if_no_conversation_id_and_no_matching_customer
    assert_difference 'Customer.count', 1 do
      Incoming.receive(load_email("conversation/conversation_1.eml"))
    end
    assert_equal 1, Customer.count
    assert_equal "DreamHost Billing Team", Customer.first.name
    customer_emails = CustomerEmail.all
    assert_equal [customer_emails[0]], Message.first.reply_to_addresses
    assert_equal [customer_emails[1], customer_emails[2]], Message.first.from_addresses
  end

  def test_add_to_existing_conversation_if_valid_conversation_id
    customer = FactoryGirl.create(:customer, :name => "Dreamhost", :customer_emails => [ CustomerEmail.new(:address => "lashes@noble.com") ], :conversations => [ Conversation.new, Conversation.new, Conversation.new ] )
    assert_no_difference 'Conversation.count' do    
      Incoming.receive(load_email("conversation/existing_conversation_1.eml"))
    end
  end 

  def test_create_conversation_and_add_to_existing_customer_if_valid_email_and_invalid_conversation_id
    customer = FactoryGirl.create(:customer, :name => "Dreamhost", :customer_emails => [ CustomerEmail.new(:address => "rebelcoo7@hotmail.com") ])
    Incoming.receive(load_email("conversation/conversation_invalid.eml"))
    assert_equal 1, Customer.count
    assert_equal 1, Conversation.count
    assert_equal 1, Message.count
    assert_equal 3, CustomerEmail.count
    assert_equal 1, Customer.first.conversations.size
  end

  def test_create_conversation_and_create_new_customer_if_invalid_conversation_id
    assert_difference "Customer.count", 1 do
      Incoming.receive(load_email("conversation/conversation_invalid.eml"))    
    end
    assert_equal "DreamHost Billing Team", Customer.first.name    
  end

  def test_create_message_with_attachments

  end


  
end
