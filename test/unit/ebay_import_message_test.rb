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
    
    @get_member_messages_request = mock_xml('get_member_messages_request.xml')
    @get_member_messages_response = mock_xml('get_member_messages_response.xml')
  end

  test "adds message to existing customer when matching user ID" do
    
    stub_request(:post, "https://api.ebay.com/ws/api.dll").with(:body => @get_member_messages_request).to_return(:body => @get_member_messages_response)
    ImportEbayMessages.new.import!

    pp Customer.all
    pp EbayMessage.all
    pp Conversation.all
    
  end

end
