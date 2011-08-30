require 'test_helper'
require 'pp'

class EbayImportTest < ActiveSupport::TestCase

  test "the truth" do
    assert true
  end

  def question(builder)
    builder.SenderID "mister_dizzy"
    builder.SenderEmail "david.p@dizzy.co.uk"
    builder.Subject "This is the subject"
    builder.Body "This is the body"
  end
  
  def build_xml
    builder = Builder::XmlMarkup.new
    builder.instruct!
    builder.GetMemberMessagesResponse do 
      builder.MemberMessage do
        builder.MemberMessageExchange do
          builder.Question do
            question(builder)
            question(builder)
            question(builder)
          end
        end
      end
    end
    puts builder.target!
    
  end

  def change_xml_attributes(xml, attributes)
    attributes.each do |k, v|
      first, second = k.split("_")
      xml.gsub!("<#{first}>#{k}</#{first}>", "<#{first}>#{v}</#{first}>")
    end
  end
  
  def mock_xml(file)
    xml_file = File.new(File.join(Rails.root.to_s, 'test', 'fixtures', 'ebay_api', 'messages', file))
    xml = xml_file.read.strip!
  end
  
  def setup    
    @customer = FactoryGirl.create(:customer, :eias_token => "abcdefghijklmnopqrstuvwxyz", :ebay_user_id => "mister_dizzy")
    
    @get_member_messages_request = mock_xml('get_member_messages_request.xml')
    @get_member_messages_response = mock_xml('get_member_messages_response.xml')
    
        stub_request(:post, "https://api.ebay.com/ws/api.dll").with(:body => @get_member_messages_request).to_return(:body => @get_member_messages_response)
  end
  
  test "build xml object" do 
    puts build_xml
  end

  test "adds messages to existing customer when matching user ID" do
    attributes = { "SenderID_1" => "mister_dizzy", "SenderEmail_1" => "david.pettifer@dizzy.co.uk", "Subject_1" => "This is the first subject", "SenderID_2" => "mister_dizzy", "SenderEmail_2" => "david.pettifer@dizzy.co.uk", "Subject_2" => "This is the first subject", "SenderID_3" => "rebelcoo7", "SenderEmail_3" => "rebelcoo@hotmail.com", "Subject_3" => "This is the second subject" }
    change_xml_attributes(@get_member_messages_response, attributes)

    before_ebay_messages = EbayMessage.count
    before_customers = Customer.count
    before_conversations = Conversation.count

    ImportEbayMessages.new.import!    
    
    assert_equal before_ebay_messages + 3, EbayMessage.count
    assert_equal before_customers + 1, Customer.count
    assert_equal before_conversations + 2, Conversation.count
    
  end
  
  test "does not add message to existing conversation when subject matches but user_id does not" do
        attributes = { "SenderID_1" => "mister_dizzy", "SenderEmail_1" => "david.pettifer@dizzy.co.uk", "Subject_1" => "This is the first subject", "SenderID_2" => "mister_dizzy", "SenderEmail_2" => "david.pettifer@dizzy.co.uk", "Subject_2" => "This is the first subject", "SenderID_3" => "rebelcoo7", "SenderEmail_3" => "rebelcoo@hotmail.com", "Subject_3" => "This is the first subject" }
        change_xml_attributes(@get_member_messages_response, attributes)
        ImportEbayMessages.new.import!     
        
        
  end
  
  test "adds message to existing conversation where subject matches and email matches but user id does not" do
    attributes = { "SenderID_1" => "mister_dizzy", "SenderEmail_1" => "david.pettifer@dizzy.co.uk", "Subject_1" => "This is the first subject", "SenderID_2" => "mrs_dizzy", "SenderEmail_2" => "david.pettifer@dizzy.co.uk", "Subject_2" => "This is the first subject", "SenderID_3" => "rebelcoo7", "SenderEmail_3" => "rebelcoo@hotmail.com", "Subject_3" => "This is the first subject" }
    change_xml_attributes(@get_member_messages_response, attributes)
    ImportEbayMessages.new.import!
    
  end
  
  test "adds ebay message to existing conversation where subject matches and email matches" do 
    conversation = @customer.conversations.build
    message = conversation.messages.build(:subject => "This is a fabulous choice of subject!", :datetime => Time.now, :content => "Body of message")
    conversation.save!
    attributes =     attributes = { "SenderID_1" => "mister_dizzy", "SenderEmail_1" => "david.pettifer@dizzy.co.uk", "Subject_1" => "This is a fabulous choice of subject!", "SenderID_2" => "mister_dizzy", "SenderEmail_2" => "david.pettifer@dizzy.co.uk", "Subject_2" => "This is the first subject", "SenderID_3" => "rebelcoo7", "SenderEmail_3" => "rebelcoo@hotmail.com", "Subject_3" => "This is the first subject" }
    change_xml_attributes(@get_member_messages_response, attributes)    
    ImportEbayMessages.new.import!
    pp Customer.all
    pp Conversation.all
    pp EbayMessage.all
  end



end

