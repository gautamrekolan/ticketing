require 'test_helper'
require 'pp'

class EbayImportTest < ActiveSupport::TestCase

  test "the truth" do
    assert true
  end
  
  def mock_xml(file)
    xml_file = File.new(File.join(Rails.root.to_s, 'test', 'fixtures', 'ebay_api', 'messages', file))
    xml = xml_file.read.strip!
  end
  
  def setup    
    @customer = FactoryGirl.create(:customer, :eias_token => "abcdefghijklmnopqrstuvwxyz", :ebay_user_id => "mister_dizzy")
    
    @user1 = { :GetUserResponse => { :User => { :Email => "david.p@dizzy.com", :EIASToken => "abcdefghijklmnopqrstuvwxyz" } } }
    @user2 = @user1.dup
    @user3 = { :GetUserResponse => { :User => { :Email => "rebelcoo77777@hotmail.com", :EIASToken => "asdfghjkl" } } }
    
    @item1 = {}
    @item2 = {}
    @item3 = {}
    
    @question1 = { :SenderID => "mister_dizzy", :SenderEmail => "david.pettifer@dizzy.co.uk", :Subject => "This is the first subject" } 
    @question2 = @question1.dup
    @question3 = { :SenderID => "rebelcoo7", :SenderEmail => "rebelcoo11111@hotmail.com", :Subject => "This is the second subject" } 
    
    @message1 = { :MemberMessageExchange => [ { :Item => @item1 }, { :Question => @question1 } ] }    
    @message2 = { :MemberMessageExchange => [ { :Item => @item2 }, { :Question => @question2 } ] }    
    @message3 = { :MemberMessageExchange => [ { :Item => @item3 }, { :Question => @question3 } ] }  
    
    @get_member_messages_response = { :GetMemberMessagesResponse => { :MemberMessage => [ @message1, @message2, @message3 ] } }
   
    @get_member_messages_request = mock_xml('get_member_messages_request.xml')    
  end
  
  def count_before
    @before_ebay_messages = EbayMessage.count
    @before_customers = Customer.count
    @before_conversations = Conversation.count
    @before_messages = Message.count
  end
  
  test "1 adds ebay message to new conversation and existing customer when matching user ID" do
    get_member_messages_response = build_xml_from_hash(@get_member_messages_response)
    stub_request(:post, "https://api.ebay.com/ws/api.dll").to_return({:body => get_member_messages_response}, {:body => build_xml_from_hash(@user1)}, {:body => build_xml_from_hash(@user2)}, {:body => build_xml_from_hash(@user3)})
 
    count_before
    ImportEbayMessages.new.import!   
    assert_equal @before_ebay_messages + 3, EbayMessage.count
    assert_equal @before_customers + 1, Customer.count
    assert_equal @before_conversations + 2, Conversation.count
  end
  
  test "2 adds ebay account customer email correctly" do  
    @item3["ItemID"] = @item1["ItemID"] = "123456"
    get_member_messages_response = build_xml_from_hash(@get_member_messages_response)
    stub_request(:post, "https://api.ebay.com/ws/api.dll").to_return({:body => get_member_messages_response}, {:body => build_xml_from_hash(@user1)}, {:body => build_xml_from_hash(@user2)}, {:body => build_xml_from_hash(@user3)})
        ImportEbayMessages.new.import!
    assert_equal ["david.pettifer@dizzy.co.uk", "david.p@dizzy.com", "rebelcoo11111@hotmail.com", "rebelcoo77777@hotmail.com"], CustomerEmail.all.collect(&:address)  
  end
  
  test "3 does not add ebay message to existing conversation when ebay message subject matches but eias_token and static email do not" do
    @question2[:SenderID] = "different_id"
    @question2[:SenderEmail] = "differentemail@diff.com"
    @user2[:GetUserResponse][:User][:EIASToken] = "booboobooboo"
    get_member_messages_response = build_xml_from_hash(@get_member_messages_response)
        stub_request(:post, "https://api.ebay.com/ws/api.dll").to_return({:body => get_member_messages_response}, {:body => build_xml_from_hash(@user1)}, {:body => build_xml_from_hash(@user2)}, {:body => build_xml_from_hash(@user3)})
        
    count_before    
    ImportEbayMessages.new.import! 
        
    assert_equal @before_conversations + 3, Conversation.count, "Conversations should have changed"
    assert_equal @before_customers + 2, Customer.count, "Customers should have changed"
    assert_equal @before_ebay_messages + 3, EbayMessage.count, "EbayMessages should have changed"
  end
  
  test "4 adds message to existing conversation where ebay message subject matches and static email matches and eias_token matches but ebay_user_id does not" do
    @question2[:SenderID] = "booboo"
    get_member_messages_response = build_xml_from_hash(@get_member_messages_response)
    stub_request(:post, "https://api.ebay.com/ws/api.dll").to_return({:body => get_member_messages_response}, {:body => build_xml_from_hash(@user1)}, {:body => build_xml_from_hash(@user2)}, {:body => build_xml_from_hash(@user3)})
 
    count_before
    ImportEbayMessages.new.import!
    
    assert_equal @before_conversations + 2, Conversation.count, "Conversations should have changed"
    assert_equal @before_customers +1, Customer.count, "Customers should have changed"
    assert_equal @before_ebay_messages +3, EbayMessage.count, "EbayMessages should have changed"
  end
  
  test "5 adds ebay message to existing conversation when ebay message subject matches message subject and static email matches" do 
    conversation = @customer.conversations.build
    message = conversation.messages.build(:subject => "This is a fabulous choice of subject!", :datetime => Time.now, :content => "Body of message")
    conversation.save!
    
    @question1[:SenderID] = @question2[:SenderID] = @question3[:SenderID] = "rahrahrah"
    @question1[:Subject] = @question2[:Subject] = @question3[:Subject] = "This is a fabulous choice of subject!"
    @question3[:SenderEmail] = "david.pettifer@dizzy.co.uk"

    get_member_messages_response = build_xml_from_hash(@get_member_messages_response)
    stub_request(:post, "https://api.ebay.com/ws/api.dll").to_return({:body => get_member_messages_response}, {:body => build_xml_from_hash(@user1)}, {:body => build_xml_from_hash(@user2)}, {:body => build_xml_from_hash(@user3)})
    
    count_before 
    ImportEbayMessages.new.import!
    pp Message.all
    pp Customer.all
    pp EbayMessage.all
    pp CustomerEmail.all
    pp Conversation.all
 
    assert_equal @before_conversations + 0, Conversation.count, "Conversations should not have changed"
    assert_equal @before_customers + 0, Customer.count, "Customers should not have changed"
    assert_equal @before_ebay_messages + 3, EbayMessage.count, "EbayMessages should have changed"
    assert_equal @before_messages + 0, Message.count, "Messages should not have changed"
  end

end
