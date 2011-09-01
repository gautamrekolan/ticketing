require 'test_helper'
require 'pp'

class EbayImportTest < ActiveSupport::TestCase

  test "the truth" do
    assert true
  end
    
  def build_xml
    builder = Builder::XmlMarkup.new
    builder.instruct!
    builder.GetMemberMessagesResponse do 
      builder.MemberMessage do
        @questions.each do |q|   
          builder.MemberMessageExchange do
            builder.Question do
              q.each do |k,v|
                builder.__send__(k, v)
              end            
            end
          end
        end
      end
    end
    builder.target!
  end
  
  def mock_xml(file)
    xml_file = File.new(File.join(Rails.root.to_s, 'test', 'fixtures', 'ebay_api', 'messages', file))
    xml = xml_file.read.strip!
  end
  
  def setup    
    @customer = FactoryGirl.create(:customer, :eias_token => "abcdefghijklmnopqrstuvwxyz", :ebay_user_id => "mister_dizzy")
    
    @message1 = { "SenderID" => "mister_dizzy", "SenderEmail" => "david.pettifer@dizzy.co.uk", "Subject" => "This is the first subject"}    
    @message2 = @message1.dup    
    @message3 = { "SenderID" => "rebelcoo7", "SenderEmail" => "rebelcoo@hotmail.com", "Subject" => "This is the second subject" }
    
    @questions = [ @message1, @message2, @message3 ]    
    @get_member_messages_request = mock_xml('get_member_messages_request.xml')    
  end
  
  def count_before
    @before_ebay_messages = EbayMessage.count
    @before_customers = Customer.count
    @before_conversations = Conversation.count
    @before_messages = Message.count
  end
  
  test "adds ebay message to new conversation and existing customer when matching user ID" do
    get_member_messages_response = build_xml
    stub_request(:post, "https://api.ebay.com/ws/api.dll").with(:body => @get_member_messages_request).to_return(:body => get_member_messages_response)

    count_before
    ImportEbayMessages.new.import!    
    
    assert_equal @before_ebay_messages + 3, EbayMessage.count
    assert_equal @before_customers + 1, Customer.count
    assert_equal @before_conversations + 2, Conversation.count
  end
  
  test "does not add message to existing conversation when ebay message subject matches but user_id and email do not" do
    @message2["SenderID"] = "different_id"
    @message2["SenderEmail"] = "differentemail"
    get_member_messages_response = build_xml
    stub_request(:post, "https://api.ebay.com/ws/api.dll").with(:body => @get_member_messages_request).to_return(:body => get_member_messages_response)
  
    count_before    
    ImportEbayMessages.new.import!     
        
    assert_equal @before_conversations + 3, Conversation.count, "Conversations should have changed"
    assert_equal @before_customers + 2, Customer.count, "Customers should have changed"
    assert_equal @before_ebay_messages + 3, EbayMessage.count, "EbayMessages should have changed"
  end
  
  test "adds message to existing conversation where ebay message subject matches and email matches but user id does not" do
    @message2["SenderID"] = "booboo"
    get_member_messages_response = build_xml
    stub_request(:post, "https://api.ebay.com/ws/api.dll").with(:body => @get_member_messages_request).to_return(:body => get_member_messages_response)
    count_before
    ImportEbayMessages.new.import!
    
    assert_equal @before_conversations + 2, Conversation.count, "Conversations should have changed"
    assert_equal @before_customers +1, Customer.count, "Customers should have changed"
    assert_equal @before_ebay_messages +3, EbayMessage.count, "EbayMessages should have changed"
  end
  
  test "adds ebay message to existing conversation where subject matches message subject and email matches" do 
    conversation = @customer.conversations.build
    message = conversation.messages.build(:subject => "This is a fabulous choice of subject!", :datetime => Time.now, :content => "Body of message")
    conversation.save!
    @message1["SenderID"] = @message2["SenderID"] = @message3["SenderID"] = "rahrahrah"
    @message1["Subject"] = @message2["Subject"] = @message3["Subject"] = "This is a fabulous choice of subject!"
    @message3["SenderEmail"] = "david.pettifer@dizzy.co.uk"
    get_member_messages_response = build_xml
    stub_request(:post, "https://api.ebay.com/ws/api.dll").with(:body => @get_member_messages_request).to_return(:body => get_member_messages_response)   
    
    count_before 
    ImportEbayMessages.new.import!
 
    assert_equal @before_conversations + 0, Conversation.count, "Conversations should not have changed"
    assert_equal @before_customers + 0, Customer.count, "Customers should not have changed"
    assert_equal @before_ebay_messages + 3, EbayMessage.count, "EbayMessages should have changed"
    assert_equal @before_messages + 0, Message.count, "Messages should not have changed"
  end

end
