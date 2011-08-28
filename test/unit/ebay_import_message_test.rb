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
  
  def register_xml_files(*responses)
      responses.collect! do |r|
        { :body => r }
      end
    stub_request(:post, "https://api.ebay.com/ws/api.dll").with(:body => mock_xml("get_my_messages_return_headers.xml")).to_return(:body => @get_my_messages_response)
  end
  
  def setup
    EbayLastImportedTime.instance.update_attributes(:last_import => Time.now)
    
    @customer = FactoryGirl.create(:customer, :eias_token => "abcdefghijklmnopqrstuvwxyz")
    
    @get_my_messages_response = mock_xml('get_my_messages_response.xml')
    @return_messages_response = mock_xml('get_return_messages_response.xml')
  end

  test "adds message to existing customer when matching user ID" do
    @return_messages_response.gsub!("jemmamadhouse", "mister-dizzy") 
    register_xml_files(@get_my_messages_response, @return_messages_response, @return_messages_response)
    result = ImportEbayMessages.new
    result.import!
    pp Customer.all
    pp EbayMessage.all
    pp Conversation.all
    
  end

end
