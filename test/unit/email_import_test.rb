require 'test_helper'
require 'pp'

class EmailImportTest < ActiveSupport::TestCase

  test "the truth" do
    assert true
  end

	def setup
		@email = File.read(Rails.root.to_s + "/test/fixtures/incoming/alternative_1.eml")
	end

	def test_receive_email_existing_customer_no_existing_conversation
		customer = FactoryGirl.create(:customer, :name => "Dreamhost", :customer_emails => [ CustomerEmail.new(:address => "billing@dreamhost.com")])
		Incoming.receive(@email)
		assert_equal 1, Message.count
		assert_equal 1, Conversation.count
		assert_equal 1, CustomerEmail.count
		assert_equal "Dreamhost", Conversation.find(1).customer.name
	end

	def test_receive_email_existing_customer_existing_conversation
		customer = FactoryGirl.create(:customer, :name => "David", :customer_emails => [ CustomerEmail.new(:address => "billing@dreamhost.com")], :conversations => [ Conversation.new ] )
		@email.gsub!("CASAMIENTO[]", "CASAMIENTO[1]")
		3.times { Incoming.receive(@email) }
		assert_equal 1, Conversation.count
		assert_equal 3, Message.count
		assert Message.all.all? { |m| m.conversation_id == 1 }
	end

	def test_receive_email_new_customer_no_existing_conversation
		customer = FactoryGirl.create(:customer)
		Incoming.receive(@email) 
		assert_equal 2, Customer.count
		assert_equal 1, Conversation.count
		assert_equal 1, Message.count
	end
  
end
